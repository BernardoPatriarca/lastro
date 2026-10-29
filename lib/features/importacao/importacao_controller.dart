import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../data/servicos/servico_importacao.dart';
import '../../data/servicos/servicos.dart';
import '../../domain/categorizacao.dart';
import '../../domain/enums.dart';
import '../../domain/importacao/csv_import.dart';
import '../../domain/importacao/leitura.dart';
import '../../domain/importacao/ofx.dart';
import '../../domain/importacao/transacao_importada.dart';

/// Arquivo escolhido pelo usuário (nome + conteúdo).
class ArquivoEscolhido {
  const ArquivoEscolhido(this.nome, this.bytes);
  final String nome;
  final Uint8List bytes;
}

/// Abre o seletor de arquivos do sistema. Os testes trocam por um falso.
final seletorDeArquivoProvider = Provider<Future<ArquivoEscolhido?> Function()>(
  (ref) => () async {
    final f = await FilePicker.pickFile(dialogTitle: 'Escolha o extrato (OFX ou CSV)');
    if (f == null) return null;
    return ArquivoEscolhido(f.name, await f.readAsBytes());
  },
);

enum TipoDestino { conta, cartao }

enum FormatoArquivo { ofx, csv, invalido }

/// Uma linha na tela de revisão.
class LinhaRevisao {
  const LinhaRevisao({
    required this.transacao,
    required this.selecionada,
    required this.duplicada,
    this.categoriaId,
    this.categoriaManual = false,
    this.ocorrenciaId,
    this.usarOcorrencia = false,
    this.porGastoFixo = false,
  });

  final TransacaoImportada transacao;

  final bool selecionada;

  /// Já foi lançada automaticamente por um gasto fixo no crédito do cartão
  /// (ex.: assinatura): importar de novo duplicaria a cobrança.
  final bool porGastoFixo;

  /// Já importada antes (chave de importação existente).
  final bool duplicada;
  final int? categoriaId;

  /// O usuário escolheu a categoria à mão (regras novas não a sobrescrevem).
  final bool categoriaManual;

  /// Conta fixa pendente que esta transação provavelmente paga.
  final int? ocorrenciaId;
  final bool usarOcorrencia;

  LinhaRevisao copiar({
    bool? selecionada,
    int? Function()? categoriaId,
    bool? categoriaManual,
    bool? usarOcorrencia,
  }) =>
      LinhaRevisao(
        transacao: transacao,
        selecionada: selecionada ?? this.selecionada,
        duplicada: duplicada,
        categoriaId: categoriaId != null ? categoriaId() : this.categoriaId,
        categoriaManual: categoriaManual ?? this.categoriaManual,
        ocorrenciaId: ocorrenciaId,
        usarOcorrencia: usarOcorrencia ?? this.usarOcorrencia,
        porGastoFixo: porGastoFixo,
      );
}

class EstadoImportacao {
  const EstadoImportacao({
    this.destino = TipoDestino.conta,
    this.contaId,
    this.cartaoId,
    this.nomeArquivo,
    this.linhas = const [],
    this.saldoBanco,
    this.dataSaldoBanco,
    this.arquivoEhCartao = false,
    this.csv,
    this.textoCsv,
    this.mapeamento,
    this.ignoradasCsv = 0,
  });

  final TipoDestino destino;
  final int? contaId;
  final int? cartaoId;
  final String? nomeArquivo;
  final List<LinhaRevisao> linhas;

  /// Saldo informado pelo banco no OFX (serve para "Ajustar saldo inicial").
  final int? saldoBanco;
  final DateTime? dataSaldoBanco;

  /// O OFX lido era de cartão de crédito.
  final bool arquivoEhCartao;

  final List<List<String>>? csv;

  /// Texto bruto do CSV (para reler com outro separador).
  final String? textoCsv;
  final MapeamentoCsv? mapeamento;
  final int ignoradasCsv;

  int? get destinoId => destino == TipoDestino.conta ? contaId : cartaoId;

  int get selecionadas => linhas.where((l) => l.selecionada).length;
  int get duplicadas => linhas.where((l) => l.duplicada).length;

  EstadoImportacao copiar({
    TipoDestino? destino,
    int? Function()? contaId,
    int? Function()? cartaoId,
    String? nomeArquivo,
    List<LinhaRevisao>? linhas,
    int? saldoBanco,
    DateTime? dataSaldoBanco,
    bool? arquivoEhCartao,
    List<List<String>>? csv,
    String? textoCsv,
    MapeamentoCsv? mapeamento,
    int? ignoradasCsv,
  }) =>
      EstadoImportacao(
        destino: destino ?? this.destino,
        contaId: contaId != null ? contaId() : this.contaId,
        cartaoId: cartaoId != null ? cartaoId() : this.cartaoId,
        nomeArquivo: nomeArquivo ?? this.nomeArquivo,
        linhas: linhas ?? this.linhas,
        saldoBanco: saldoBanco ?? this.saldoBanco,
        dataSaldoBanco: dataSaldoBanco ?? this.dataSaldoBanco,
        arquivoEhCartao: arquivoEhCartao ?? this.arquivoEhCartao,
        csv: csv ?? this.csv,
        textoCsv: textoCsv ?? this.textoCsv,
        mapeamento: mapeamento ?? this.mapeamento,
        ignoradasCsv: ignoradasCsv ?? this.ignoradasCsv,
      );
}

/// Conduz a importação: ler arquivo → (mapear CSV) → revisar → confirmar.
class ImportacaoController extends Notifier<EstadoImportacao> {
  @override
  EstadoImportacao build() => const EstadoImportacao();

  void limpar() => state = const EstadoImportacao();

  void definirDestino(TipoDestino tipo, int? id) {
    state = tipo == TipoDestino.conta
        ? state.copiar(destino: tipo, contaId: () => id)
        : state.copiar(destino: tipo, cartaoId: () => id);
  }

  String get _prefixoChave => state.destino == TipoDestino.conta
      ? 'c${state.contaId}'
      : 'k${state.cartaoId}';

  /// Lê o arquivo escolhido. OFX já vai para a revisão; CSV espera o mapeamento.
  Future<FormatoArquivo> carregar(ArquivoEscolhido arquivo) async {
    final texto = decodificarTexto(arquivo.bytes);
    if (pareceOfx(texto)) {
      final ofx = lerOfx(texto);
      if (ofx.transacoes.isEmpty) return FormatoArquivo.invalido;
      state = state.copiar(
        nomeArquivo: arquivo.nome,
        saldoBanco: ofx.saldoFinal,
        dataSaldoBanco: ofx.dataSaldo,
        arquivoEhCartao: ofx.ehCartao,
      );
      await _prepararLinhas(ofx.transacoes);
      return FormatoArquivo.ofx;
    }
    final separador = detectarSeparador(texto);
    final linhas = lerCsv(texto, separador: separador);
    if (linhas.length < 2 || linhas.first.length < 2) return FormatoArquivo.invalido;
    state = state.copiar(
      nomeArquivo: arquivo.nome,
      csv: linhas,
      textoCsv: texto,
      mapeamento: sugerirMapeamento(linhas.first, separador: separador).copiar(
        positivoEhGasto: state.destino == TipoDestino.cartao,
      ),
    );
    return FormatoArquivo.csv;
  }

  /// Muda o mapeamento do CSV (a tela de mapeamento chama a cada ajuste).
  void definirMapeamento(MapeamentoCsv m) => state = state.copiar(mapeamento: m);

  /// Relê o CSV com outro separador, mantendo as demais escolhas.
  void trocarSeparador(String separador) {
    final texto = state.textoCsv;
    if (texto == null) return;
    final linhas = lerCsv(texto, separador: separador);
    state = state.copiar(
      csv: linhas,
      mapeamento: (state.mapeamento ?? sugerirMapeamento(linhas.first, separador: separador))
          .copiar(separador: separador),
    );
  }

  /// Converte o CSV com o mapeamento atual e abre a revisão.
  Future<ResultadoCsv> aplicarMapeamento() async {
    final r = converterCsv(state.csv!, state.mapeamento!);
    state = state.copiar(ignoradasCsv: r.ignoradas);
    await _prepararLinhas(r.transacoes);
    return r;
  }

  /// Pré-visualização sem gravar nada (conta quantas linhas seriam lidas).
  ResultadoCsv previaCsv() => converterCsv(state.csv!, state.mapeamento!);

  Future<void> _prepararLinhas(List<TransacaoImportada> brutas) async {
    final db = ref.read(bancoProvider);
    final existentes = await ref.read(servicoImportacaoProvider).chavesExistentes();
    final comChave = atribuirChaves(brutas, prefixo: _prefixoChave);
    final duplicadas = chavesDuplicadas(comChave, existentes);
    final regras = await _regras();
    final pendentes = [
      for (final o in await db.compromissosDao.todasOcorrencias())
        if (o.status == StatusOcorrencia.pendente)
          OcorrenciaPendenteSimples(id: o.id, valor: o.valor, vencimento: o.dataVencimento),
    ];

    // Casar com contas fixas pendentes só faz sentido para extrato de conta.
    final casamento = state.destino == TipoDestino.conta
        ? casarComOcorrencias(comChave, pendentes)
        : const <int, int>{};

    final cartao = state.destino == TipoDestino.cartao;

    // Fatura de cartão: cobranças de gasto fixo no crédito já foram lançadas
    // sozinhas. Mesmo valor perto da data = a mesma cobrança: fica desmarcada.
    final porFixo = <int, int>{};
    if (cartao && state.cartaoId != null) {
      porFixo.addAll(casarComOcorrencias(comChave, [
        for (final l in await db.lancamentosDao.todos())
          if (l.cartaoId == state.cartaoId && l.ocorrenciaCompromissoId != null)
            OcorrenciaPendenteSimples(id: l.id, valor: l.valor, vencimento: l.data),
      ]));
    }

    state = state.copiar(linhas: [
      for (var i = 0; i < comChave.length; i++)
        LinhaRevisao(
          transacao: comChave[i],
          duplicada: duplicadas.contains(comChave[i].chave) || porFixo.containsKey(i),
          porGastoFixo: porFixo.containsKey(i),
          // Duplicadas ficam desmarcadas. Em fatura de cartão, entradas
          // (estornos, "pagamento recebido") também começam desmarcadas.
          selecionada: !duplicadas.contains(comChave[i].chave) &&
              !porFixo.containsKey(i) &&
              !(cartao && !comChave[i].ehSaida),
          categoriaId: categoriaSugerida(comChave[i].descricao, regras),
          ocorrenciaId: casamento[i],
          usarOcorrencia: casamento[i] != null && !duplicadas.contains(comChave[i].chave),
        ),
    ]);
  }

  /// Regras lidas direto do banco (não dependem de nenhuma tela observando).
  Future<List<RegraSimples>> _regras() async => [
        for (final r in await ref.read(bancoProvider).categoriasDao.todasRegras())
          RegraSimples(
            id: r.id,
            padrao: r.padrao,
            categoriaId: r.categoriaId,
            prioridade: r.prioridade,
          ),
      ];

  void alternar(int i) => _atualizar(i, (l) => l.copiar(selecionada: !l.selecionada));

  void selecionarTodas(bool v) {
    state = state.copiar(linhas: [
      for (final l in state.linhas)
        l.copiar(selecionada: v && !(state.destino == TipoDestino.cartao && !l.transacao.ehSaida)),
    ]);
  }

  void definirCategoria(int i, int? categoriaId) => _atualizar(
        i,
        (l) => l.copiar(categoriaId: () => categoriaId, categoriaManual: true),
      );

  void alternarOcorrencia(int i) =>
      _atualizar(i, (l) => l.copiar(usarOcorrencia: !l.usarOcorrencia));

  /// Reaplica as regras (inclusive uma recém-criada) às linhas cuja
  /// categoria não foi escolhida à mão.
  Future<void> reaplicarRegras() async {
    final regras = await _regras();
    state = state.copiar(linhas: [
      for (final l in state.linhas)
        l.categoriaManual
            ? l
            : l.copiar(categoriaId: () => categoriaSugerida(l.transacao.descricao, regras)),
    ]);
  }

  void _atualizar(int i, LinhaRevisao Function(LinhaRevisao) f) {
    final novas = [...state.linhas];
    novas[i] = f(novas[i]);
    state = state.copiar(linhas: novas);
  }

  /// Grava as linhas selecionadas. Devolve o resumo.
  Future<ResumoImportacao> confirmar() async {
    final servico = ref.read(servicoImportacaoProvider);
    final escolhidas = [
      for (final l in state.linhas)
        if (l.selecionada)
          LinhaParaImportar(
            transacao: l.transacao,
            categoriaId: l.categoriaId,
            ocorrenciaId: l.usarOcorrencia ? l.ocorrenciaId : null,
          ),
    ];
    if (state.destino == TipoDestino.conta) {
      return servico.importarParaConta(state.contaId!, escolhidas);
    }
    final cartao = await ref.read(bancoProvider).cartoesDao.obter(state.cartaoId!);
    return servico.importarParaCartao(cartao!, escolhidas);
  }
}

final importacaoProvider =
    NotifierProvider<ImportacaoController, EstadoImportacao>(ImportacaoController.new);
