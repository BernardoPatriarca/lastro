import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatadores/data.dart';
import '../../core/formatadores/moeda.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/cores_lastro.dart';
import '../../core/widgets/campo_valor.dart';
import '../../data/banco.dart';
import '../../data/derivados.dart';
import '../../data/providers.dart';
import '../../data/servicos/servico_cartao.dart';
import '../../data/servicos/servicos.dart';
import '../../domain/datas.dart';
import '../../domain/enums.dart';
import '../../domain/parcelas.dart';
import '../cartoes/impacto_credito.dart';
import '../cartoes/previa_compra.dart';
import '../categorias/seletor_categoria.dart';
import 'lancamento_acoes.dart';

enum _Aba { gasto, ganho, movimento }

enum _SubMovimento { transferencia, aporte, resgate }

/// Lançamento rápido ("+") e edição de lançamento.
class LancamentoFormPage extends ConsumerStatefulWidget {
  const LancamentoFormPage({
    super.key,
    this.id,
    this.tipoInicial,
    this.contaInicial,
  });

  /// Edição quando não nulo.
  final int? id;

  /// `gasto`, `ganho` ou `mov` (só na criação).
  final String? tipoInicial;

  /// Conta já escolhida (ex.: "Transferir" a partir da tela de contas).
  final int? contaInicial;

  @override
  ConsumerState<LancamentoFormPage> createState() => _LancamentoFormPageState();
}

class _LancamentoFormPageState extends ConsumerState<LancamentoFormPage> {
  final _chave = GlobalKey<FormState>();
  final _valor = ControladorValor();
  final _descricao = TextEditingController();

  Lancamento? _original;
  bool _carregando = false;
  bool _salvando = false;

  _Aba _aba = _Aba.gasto;
  _SubMovimento _sub = _SubMovimento.transferencia;
  int? _categoriaId;
  FormaPagamento _forma = FormaPagamento.pix;
  int? _contaId;
  int? _contaDestinoId;
  int? _cartaoId;
  int? _investimentoId;
  int _parcelas = 1;

  // "Gasto fixo" (cria compromisso) e "Repetir todo mês" (cria receita).
  bool _fixo = false;
  TipoCompromisso _tipoFixo = TipoCompromisso.recorrente;
  int _parcelasFixo = 12;
  bool _repetir = false;

  /// Compra parcelada em edição: parcela N de M.
  CompraParcelada? _compra;
  DateTime _data = soData(DateTime.now());

  bool get _edicao => widget.id != null;

  bool get _credito => _aba == _Aba.gasto && _forma == FormaPagamento.credito;

  /// Editando uma compra no crédito: a forma de pagamento não muda.
  bool get _editandoCredito =>
      _original?.formaPagamento == FormaPagamento.credito;

  /// Lançamentos criados pelo app (fatura, ajuste) só aceitam descrição/data.
  bool get _restrito =>
      _original != null &&
      (_original!.tipo == TipoLancamento.pagamentoFatura ||
          _original!.tipo == TipoLancamento.ajusteSaldo);

  @override
  void initState() {
    super.initState();
    _aba = switch (widget.tipoInicial) {
      'ganho' => _Aba.ganho,
      'mov' => _Aba.movimento,
      _ => _Aba.gasto,
    };
    _contaId = widget.contaInicial;
    if (_edicao) {
      _carregando = true;
      _carregar();
    }
  }

  Future<void> _carregar() async {
    final dao = ref.read(bancoProvider).lancamentosDao;
    final l = await dao.obter(widget.id!);
    if (!mounted) return;
    if (l == null) {
      context.pop();
      return;
    }
    final compra =
        l.compraParceladaId == null ? null : await dao.compra(l.compraParceladaId!);
    if (!mounted) return;
    _compra = compra;
    setState(() {
      _original = l;
      _carregando = false;
      _valor.centavos = l.valor.abs();
      _descricao.text = compra == null ? l.descricao : descricaoBase(l.descricao);
      _categoriaId = l.categoriaId;
      _contaId = l.contaId;
      _contaDestinoId = l.contaDestinoId;
      _data = l.data;
      _cartaoId = l.cartaoId;
      _investimentoId = l.investimentoId;
      if (l.formaPagamento != null) _forma = l.formaPagamento!;
      switch (l.tipo) {
        case TipoLancamento.ganho:
          _aba = _Aba.ganho;
        case TipoLancamento.transferencia:
          _aba = _Aba.movimento;
          _sub = _SubMovimento.transferencia;
        case TipoLancamento.aporte:
          _aba = _Aba.movimento;
          _sub = _SubMovimento.aporte;
        case TipoLancamento.resgate:
          _aba = _Aba.movimento;
          _sub = _SubMovimento.resgate;
        default:
          _aba = _Aba.gasto;
      }
    });
  }

  @override
  void dispose() {
    _valor.dispose();
    _descricao.dispose();
    super.dispose();
  }

  TipoLancamento get _tipo => switch (_aba) {
        _Aba.gasto => TipoLancamento.gasto,
        _Aba.ganho => TipoLancamento.ganho,
        _Aba.movimento => switch (_sub) {
            _SubMovimento.transferencia => TipoLancamento.transferencia,
            _SubMovimento.aporte => TipoLancamento.aporte,
            _SubMovimento.resgate => TipoLancamento.resgate,
          },
      };

  Future<void> _escolherData() async {
    final nova = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (nova != null) setState(() => _data = soData(nova));
  }

  Future<void> _salvar() async {
    if (!_chave.currentState!.validate() || _salvando) return;
    final contas = ref.read(contasAtivasProvider);
    final contaId = _contaId ?? (contas.isNotEmpty ? contas.first.id : null);
    final cartoes = ref.read(cartoesProvider).ou;
    final cartaoId = _cartaoId ?? (cartoes.isNotEmpty ? cartoes.first.id : null);

    if (_credito || _editandoCredito) {
      if (cartaoId == null) {
        _aviso('Cadastre um cartão antes de lançar no crédito.');
        return;
      }
    } else if (!_restrito && contaId == null) {
      _aviso('Cadastre uma conta antes de lançar.');
      return;
    }

    // Compra nova no crédito: aplica o comportamento do crédito seguro
    // (avisar / confirmar / bloquear) antes de travar o botão.
    if (_credito && !_edicao) {
      final cartao = cartoes.firstWhere((c) => c.id == cartaoId);
      if (!await _liberadoPeloCreditoSeguro(cartao)) return;
    }

    setState(() => _salvando = true);
    try {
      final servico = ref.read(servicoLancamentosProvider);
      final cartaoServico = ref.read(servicoCartaoProvider);
      final original = _original;
      final cartao = cartaoId == null
          ? null
          : cartoes.firstWhere((c) => c.id == cartaoId);

      if (original != null && _editandoCredito && !_restrito) {
        if (_compra != null) {
          if (!mounted) return;
          final escopo = await perguntarEscopo(
            context,
            titulo: 'Aplicar a alteração em quais parcelas?',
            permitirTodas: true,
          );
          if (escopo == null) return;
          await cartaoServico.atualizarParcelas(
            original,
            escopo,
            valorParcela: _valor.centavos,
            descricaoBase: _descricao.text,
            categoriaId: _categoriaId,
          );
        } else {
          await cartaoServico.atualizarCompraUnica(
            original,
            cartao: cartao!,
            valor: _valor.centavos,
            data: _data,
            descricao: _descricao.text,
            categoriaId: _categoriaId,
          );
        }
      } else if (original != null) {
        await servico.atualizar(_restrito
            ? original.copyWith(data: _data, descricao: _descricao.text.trim())
            : original.copyWith(
                tipo: _tipo,
                valor: _valor.centavos,
                data: _data,
                descricao: _descricao.text.trim(),
                categoriaId: Value(_aba == _Aba.movimento ? null : _categoriaId),
                formaPagamento: Value(_aba == _Aba.gasto ? _forma : null),
                contaId: Value(contaId),
                contaDestinoId: Value(
                  _tipo == TipoLancamento.transferencia ? _contaDestinoId : null,
                ),
              ));
      } else if (_fixo && _aba == _Aba.gasto && !_credito) {
        final categorias = ref.read(categoriasPorIdProvider);
        final texto = _descricao.text.trim();
        await ref.read(servicoCompromissoProvider).criarCompromisso(
              descricao: texto.isNotEmpty
                  ? texto
                  : (categorias[_categoriaId]?.nome ?? 'Gasto fixo'),
              valor: _valor.centavos,
              tipo: _tipoFixo,
              dataInicio: _data,
              numeroParcelas: _parcelasFixo,
              forma: _forma,
              categoriaId: _categoriaId,
              contaId: contaId,
            );
        if (!mounted) return;
        context.pop();
        mostrarAviso(context, 'Gasto fixo criado: aparece em Pendentes para você pagar.');
        return;
      } else if (_credito) {
        await cartaoServico.registrarCompra(
          cartao: cartao!,
          valorTotal: _valor.centavos,
          parcelas: _parcelas,
          data: _data,
          descricao: _descricao.text,
          categoriaId: _categoriaId,
        );
      } else if (_tipo == TipoLancamento.aporte || _tipo == TipoLancamento.resgate) {
        // Aporte/resgate: com investimento escolhido, também vira movimento dele.
        final inv = ref.read(servicoInvestimentoProvider);
        if (_tipo == TipoLancamento.aporte) {
          await inv.aportar(
            contaId: contaId!,
            valor: _valor.centavos,
            data: _data,
            investimentoId: _investimentoId,
            descricao: _descricao.text,
          );
        } else {
          await inv.resgatar(
            contaId: contaId!,
            valor: _valor.centavos,
            data: _data,
            investimentoId: _investimentoId,
            descricao: _descricao.text,
          );
        }
      } else {
        await servico.registrar(
          tipo: _tipo,
          valor: _valor.centavos,
          data: _data,
          descricao: _descricao.text,
          categoriaId: _aba == _Aba.movimento ? null : _categoriaId,
          forma: _aba == _Aba.gasto ? _forma : null,
          contaId: contaId,
          contaDestinoId:
              _tipo == TipoLancamento.transferencia ? _contaDestinoId : null,
        );
        // "Repetir todo mês": o ganho de agora é real; a receita recorrente
        // começa no mês seguinte para não aparecer em dobro em Pendentes.
        if (_repetir && _aba == _Aba.ganho) {
          final texto = _descricao.text.trim();
          await ref.read(servicoCompromissoProvider).criarReceita(
                descricao: texto.isNotEmpty
                    ? texto
                    : (ref.read(categoriasPorIdProvider)[_categoriaId]?.nome ?? 'Receita'),
                valorPrevisto: _valor.centavos,
                contaId: contaId!,
                dataInicio: somarMeses(_data, 1),
                diaPrevisto: _data.day,
                categoriaId: _categoriaId,
              );
        }
      }
      if (!mounted) return;
      context.pop();
      mostrarAviso(context, _edicao ? 'Lançamento atualizado' : 'Lançamento salvo');
    } on OperacaoInvalida catch (e) {
      if (mounted) _aviso(e.mensagem);
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  /// Aplica o comportamento configurado quando a compra estoura o crédito
  /// seguro (CLAUDE.md 5.1): avisar, confirmar ou bloquear.
  Future<bool> _liberadoPeloCreditoSeguro(Cartao cartao) async {
    final impacto = impactoDaCompra(
      ref,
      cartao: cartao,
      valor: _valor.centavos,
      parcelas: _parcelas,
      data: _data,
    );
    if (!impacto.estoura) return true;
    final valorAcima = Moeda.formatar(impacto.acimaDoSaldo);
    switch (ref.read(ajustesProvider).comportamentoEstouro) {
      case ComportamentoEstouro.avisar:
        return true;
      case ComportamentoEstouro.bloquear:
        _aviso('Compra bloqueada: a fatura ficaria $valorAcima acima do seu '
            'saldo. Mude isso em Configurações › Crédito seguro.');
        return false;
      case ComportamentoEstouro.confirmar:
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            icon: Icon(Icons.warning_amber_rounded, color: Theme.of(ctx).colorScheme.error),
            title: const Text('Passou do seu saldo'),
            content: Text(
              'Essa compra deixa a fatura $valorAcima acima do seu saldo. '
              'Você não terá dinheiro para pagá-la. Lançar mesmo assim?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(120, 44),
                  backgroundColor: Theme.of(ctx).colorScheme.error,
                  foregroundColor: Theme.of(ctx).colorScheme.onError,
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Lançar mesmo assim'),
              ),
            ],
          ),
        );
        return ok == true;
    }
  }

  void _aviso(String texto) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(SnackBar(
      content: Text(texto),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = context.coresLastro;
    final contas = ref.watch(contasAtivasProvider);
    final semContas = ref.watch(contasProvider).hasValue && contas.isEmpty;
    final corValor = switch (_aba) {
      _Aba.gasto => cores.negativo,
      _Aba.ganho => cores.positivo,
      _Aba.movimento => tema.colorScheme.onSurface,
    };
    final contaId = _contaId ?? (contas.isNotEmpty ? contas.first.id : null);
    final semCartoes = ref.watch(cartoesProvider).hasValue &&
        ref.watch(cartoesProvider).ou.isEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Fechar',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(_edicao ? 'Editar lançamento' : 'Novo lançamento'),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Form(
                key: _chave,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        children: [
                          if (!_edicao)
                            SegmentedButton<_Aba>(
                              showSelectedIcon: false,
                              segments: const [
                                ButtonSegment(
                                  value: _Aba.gasto,
                                  label: Text('Gasto'),
                                  icon: Icon(Icons.arrow_downward_rounded),
                                ),
                                ButtonSegment(
                                  value: _Aba.ganho,
                                  label: Text('Ganho'),
                                  icon: Icon(Icons.arrow_upward_rounded),
                                ),
                                ButtonSegment(
                                  value: _Aba.movimento,
                                  label: Text('Transf.'),
                                  icon: Icon(Icons.swap_horiz_rounded),
                                ),
                              ],
                              selected: {_aba},
                              onSelectionChanged: (s) =>
                                  setState(() => _aba = s.first),
                            ),
                          if (_restrito)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: _Aviso(
                                'Lançamento gerado pelo app: só a data e a '
                                'descrição podem ser alteradas.',
                              ),
                            ),
                          const SizedBox(height: 8),
                          IgnorePointer(
                            ignoring: _restrito,
                            child: Opacity(
                              opacity: _restrito ? 0.6 : 1,
                              child: CampoValor(
                                controller: _valor,
                                grande: true,
                                autofocus: !_edicao,
                                cor: corValor,
                                validator: (_) => _valor.centavos <= 0
                                    ? 'Informe um valor maior que zero'
                                    : null,
                              ),
                            ),
                          ),
                          if (_compra != null && _original != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: _Aviso(
                                'Parcela ${_original!.parcelaNumero} de '
                                '${_compra!.numeroParcelas} · compra de '
                                '${Moeda.formatar(_compra!.valorTotal)}. '
                                'O valor aqui é o de cada parcela.',
                              ),
                            ),
                          if (semCartoes && (_credito || _editandoCredito)) ...[
                            const SizedBox(height: 8),
                            _Aviso(
                              'Você ainda não tem um cartão cadastrado.',
                              acao: 'Cadastrar',
                              onAcao: () => context.push(Rotas.novoCartao),
                            ),
                          ],
                          if (semContas && !_restrito && !_credito) ...[
                            const SizedBox(height: 8),
                            _Aviso(
                              'Você ainda não tem uma conta. Crie uma para '
                              'registrar lançamentos.',
                              acao: 'Criar conta',
                              onAcao: () => context.push(Rotas.novaConta),
                            ),
                          ],
                          if (!_restrito) ..._camposPrincipais(contas, contaId),
                          const SizedBox(height: 20),
                          IgnorePointer(
                            ignoring: _compra != null,
                            child: Opacity(
                              opacity: _compra != null ? 0.5 : 1,
                              child: _Secao(
                            'Data',
                            child: Row(
                              children: [
                                ActionChip(
                                  avatar: const Icon(Icons.event_rounded, size: 18),
                                  label: Text(FormatoData.dia(_data)),
                                  onPressed: _escolherData,
                                ),
                                const SizedBox(width: 8),
                                ChoiceChip(
                                  label: const Text('Hoje'),
                                  selected: mesmoDia(_data, DateTime.now()),
                                  showCheckmark: false,
                                  onSelected: (_) => setState(
                                      () => _data = soData(DateTime.now())),
                                ),
                                const SizedBox(width: 8),
                                ChoiceChip(
                                  label: const Text('Ontem'),
                                  selected: mesmoDia(
                                    _data,
                                    DateTime.now().subtract(const Duration(days: 1)),
                                  ),
                                  showCheckmark: false,
                                  onSelected: (_) => setState(() => _data = soData(
                                        DateTime.now()
                                            .subtract(const Duration(days: 1)),
                                      )),
                                ),
                              ],
                            ),
                          ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _descricao,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              labelText: 'Descrição (opcional)',
                              prefixIcon: Icon(Icons.notes_rounded),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                      child: FilledButton(
                        onPressed: _salvando ? null : _salvar,
                        child: _salvando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.5),
                              )
                            : Text(_edicao ? 'Salvar alterações' : 'Salvar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  /// Cartão, parcelas e prévia da fatura (compra no crédito).
  List<Widget> _camposCredito() {
    final cartoes = [for (final c in ref.watch(cartoesProvider).ou) if (c.ativo) c];
    final cartaoId = _cartaoId ?? (cartoes.isNotEmpty ? cartoes.first.id : null);
    final cartao = cartoes.where((c) => c.id == cartaoId).firstOrNull;
    final parcelada = _compra != null;
    return [
      _Secao(
        'Cartão',
        child: DropdownButtonFormField<int>(
          key: ValueKey('${cartoes.length}-$cartaoId'),
          initialValue: cartao?.id,
          isExpanded: true,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.credit_card_rounded)),
          hint: const Text('Escolha o cartão'),
          items: [
            for (final c in cartoes) DropdownMenuItem(value: c.id, child: Text(c.nome)),
          ],
          // Parcelas já geradas ficam no cartão original.
          onChanged: parcelada ? null : (v) => setState(() => _cartaoId = v),
        ),
      ),
      if (!_edicao) ...[
        const SizedBox(height: 20),
        _Secao(
          'Parcelas',
          child: SeletorParcelas(
            parcelas: _parcelas,
            onChanged: (n) => setState(() => _parcelas = n),
          ),
        ),
      ],
      if (cartao != null && !parcelada) ...[
        const SizedBox(height: 16),
        ListenableBuilder(
          listenable: _valor,
          builder: (_, _) => Column(
            children: [
              PreviaCompra(
                cartao: cartao,
                valorTotal: _valor.centavos,
                parcelas: _edicao ? 1 : _parcelas,
                data: _data,
              ),
              // O impacto vale para compras novas (já lançadas contam no saldo).
              if (!_edicao) ...[
                const SizedBox(height: 10),
                ImpactoCredito(
                  cartao: cartao,
                  valor: _valor.centavos,
                  parcelas: _parcelas,
                  data: _data,
                ),
              ],
            ],
          ),
        ),
      ],
    ];
  }

  List<Widget> _camposPrincipais(List<Conta> contas, int? contaId) {
    return [
      if (_aba == _Aba.movimento) ...[
        const SizedBox(height: 16),
        SegmentedButton<_SubMovimento>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: _SubMovimento.transferencia, label: Text('Transferência')),
            ButtonSegment(value: _SubMovimento.aporte, label: Text('Aporte')),
            ButtonSegment(value: _SubMovimento.resgate, label: Text('Resgate')),
          ],
          selected: {_sub},
          onSelectionChanged: (s) => setState(() => _sub = s.first),
        ),
      ],
      if (_aba != _Aba.movimento) ...[
        const SizedBox(height: 20),
        _Secao(
          'Categoria',
          child: SeletorCategoria(
            tipo: _aba == _Aba.gasto ? TipoCategoria.gasto : TipoCategoria.ganho,
            selecionada: _categoriaId,
            onSelecionar: (id) => setState(() => _categoriaId = id),
          ),
        ),
      ],
      if (_aba == _Aba.gasto && !_editandoCredito) ...[
        const SizedBox(height: 20),
        _Secao(
          'Forma de pagamento',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in FormaPagamento.values)
                // Ao editar um lançamento existente a forma "crédito" não
                // entra: ele já nasceu como débito/pix/etc.
                if (f != FormaPagamento.credito || !_edicao)
                  ChoiceChip(
                    label: Text(f.rotulo),
                    selected: _forma == f,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _forma = f),
                  ),
            ],
          ),
        ),
      ],
      const SizedBox(height: 20),
      if (_credito || _editandoCredito) ..._camposCredito() else
      _Secao(
        _tipo == TipoLancamento.transferencia
            ? 'De (conta de origem)'
            : _tipo == TipoLancamento.resgate
                ? 'Para (conta que recebe)'
                : _tipo == TipoLancamento.aporte
                    ? 'Sai da conta'
                    : 'Conta',
        child: _SeletorConta(
          contas: contas,
          selecionada: contaId,
          onSelecionar: (id) => setState(() => _contaId = id),
        ),
      ),
      if (_tipo == TipoLancamento.transferencia) ...[
        const SizedBox(height: 20),
        _Secao(
          'Para (conta de destino)',
          child: _SeletorConta(
            contas: [for (final c in contas) if (c.id != contaId) c],
            selecionada: _contaDestinoId,
            onSelecionar: (id) => setState(() => _contaDestinoId = id),
            validator: (v) => v == null ? 'Escolha a conta de destino' : null,
          ),
        ),
      ],
      if (!_edicao &&
          (_tipo == TipoLancamento.aporte || _tipo == TipoLancamento.resgate))
        ..._campoInvestimento(),
      if (!_edicao && _aba == _Aba.gasto && !_credito) ..._camposFixo(),
      if (!_edicao && _aba == _Aba.ganho)
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _repetir,
          onChanged: (v) => setState(() => _repetir = v),
          title: const Text('Repetir todo mês'),
          subtitle: const Text(
            'Cria uma receita recorrente: todo mês ela aparece em Pendentes '
            'para você confirmar.',
          ),
        ),
    ];
  }

  /// Aporte/resgate: investimento ao qual o movimento pertence (opcional).
  List<Widget> _campoInvestimento() {
    final investimentos = [for (final i in ref.watch(investimentosProvider).ou) if (i.ativo) i];
    if (investimentos.isEmpty) return const [];
    final valido = investimentos.any((i) => i.id == _investimentoId) ? _investimentoId : null;
    return [
      const SizedBox(height: 20),
      _Secao(
        'Investimento',
        child: DropdownButtonFormField<int?>(
          key: ValueKey('${investimentos.length}-$valido'),
          initialValue: valido,
          isExpanded: true,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.savings_outlined)),
          items: [
            const DropdownMenuItem<int?>(value: null, child: Text('Não vincular')),
            for (final i in investimentos)
              DropdownMenuItem<int?>(value: i.id, child: Text(i.nome)),
          ],
          onChanged: (v) => setState(() => _investimentoId = v),
        ),
      ),
    ];
  }

  /// "Gasto fixo": em vez de lançar agora, cria um compromisso (recorrente ou
  /// parcelado) que gera uma conta pendente por mês.
  List<Widget> _camposFixo() => [
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _fixo,
          onChanged: (v) => setState(() => _fixo = v),
          title: const Text('Gasto fixo'),
          subtitle: const Text(
            'Aluguel, internet, financiamento… aparece em Pendentes todo mês.',
          ),
        ),
        if (_fixo) ...[
          const SizedBox(height: 4),
          SegmentedButton<TipoCompromisso>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: TipoCompromisso.recorrente, label: Text('Sem fim')),
              ButtonSegment(value: TipoCompromisso.parcelado, label: Text('Parcelado')),
            ],
            selected: {_tipoFixo},
            onSelectionChanged: (s) => setState(() => _tipoFixo = s.first),
          ),
          if (_tipoFixo == TipoCompromisso.parcelado) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Expanded(child: Text('Número de parcelas')),
                IconButton.filledTonal(
                  onPressed: _parcelasFixo > 2 ? () => setState(() => _parcelasFixo--) : null,
                  icon: const Icon(Icons.remove_rounded),
                ),
                SizedBox(
                  width: 48,
                  child: Text('$_parcelasFixo',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                IconButton.filledTonal(
                  onPressed: _parcelasFixo < 120 ? () => setState(() => _parcelasFixo++) : null,
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
          ],
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'O valor acima é o de cada mês. A data escolhida será o primeiro '
              'vencimento (todo dia ${_data.day}).',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ];
}

class _SeletorConta extends StatelessWidget {
  const _SeletorConta({
    required this.contas,
    required this.selecionada,
    required this.onSelecionar,
    this.validator,
  });
  final List<Conta> contas;
  final int? selecionada;
  final ValueChanged<int?> onSelecionar;
  final String? Function(int?)? validator;

  @override
  Widget build(BuildContext context) {
    final valida = contas.any((c) => c.id == selecionada) ? selecionada : null;
    return DropdownButtonFormField<int>(
      key: ValueKey('${contas.length}-$valida'),
      initialValue: valida,
      isExpanded: true,
      decoration: const InputDecoration(prefixIcon: Icon(Icons.account_balance_wallet_outlined)),
      hint: const Text('Escolha a conta'),
      items: [
        for (final c in contas) DropdownMenuItem(value: c.id, child: Text(c.nome)),
      ],
      onChanged: onSelecionar,
      validator: validator,
    );
  }
}

class _Secao extends StatelessWidget {
  const _Secao(this.titulo, {required this.child});
  final String titulo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso(this.texto, {this.acao, this.onAcao});
  final String texto;
  final String? acao;
  final VoidCallback? onAcao;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tema.colorScheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: tema.colorScheme.secondary),
          const SizedBox(width: 12),
          Expanded(child: Text(texto, style: tema.textTheme.bodyMedium)),
          if (acao != null) TextButton(onPressed: onAcao, child: Text(acao!)),
        ],
      ),
    );
  }
}
