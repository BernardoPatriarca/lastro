import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatadores/data.dart';
import '../../core/formatadores/moeda.dart';
import '../../core/router/app_router.dart';
import '../../data/providers.dart';
import '../../data/servicos/servicos.dart';
import '../../domain/importacao/csv_import.dart';
import '../lancamentos/lancamento_acoes.dart';
import 'importacao_controller.dart';

/// Mapeamento das colunas do CSV: data, descrição, valor e (se houver) tipo.
/// O mapeamento pode ser salvo com o nome do banco para os próximos arquivos.
class MapearCsvPage extends ConsumerStatefulWidget {
  const MapearCsvPage({super.key});

  @override
  ConsumerState<MapearCsvPage> createState() => _MapearCsvPageState();
}

class _MapearCsvPageState extends ConsumerState<MapearCsvPage> {
  final _nomeBanco = TextEditingController();
  bool _continuando = false;

  @override
  void dispose() {
    _nomeBanco.dispose();
    super.dispose();
  }

  String _rotuloColuna(List<List<String>> linhas, MapeamentoCsv m, int i) {
    final amostra = linhas.length > (m.temCabecalho ? 1 : 0)
        ? linhas[m.temCabecalho ? 1 : 0]
        : linhas.first;
    final nome = m.temCabecalho && i < linhas.first.length ? linhas.first[i] : 'Coluna ${i + 1}';
    final ex = i < amostra.length ? amostra[i] : '';
    final curto = ex.length > 22 ? '${ex.substring(0, 22)}…' : ex;
    return '${i + 1} · $nome${curto.isEmpty ? '' : '  ($curto)'}';
  }

  Future<void> _continuar() async {
    final ctl = ref.read(importacaoProvider.notifier);
    setState(() => _continuando = true);
    final m = ref.read(importacaoProvider).mapeamento!;
    final r = await ctl.aplicarMapeamento();
    if (!mounted) return;
    setState(() => _continuando = false);
    if (r.transacoes.isEmpty) {
      mostrarAviso(context, 'Nenhuma transação válida com esse mapeamento. '
          'Confira as colunas e o formato da data.');
      return;
    }
    final nome = _nomeBanco.text.trim();
    if (nome.isNotEmpty) {
      await ref.read(servicoImportacaoProvider).salvarMapeamento(
            nome: nome,
            separador: m.separador,
            temCabecalho: m.temCabecalho,
            colunaData: m.colunaData,
            colunaDescricao: m.colunaDescricao,
            colunaValor: m.colunaValor,
            colunaTipo: m.colunaTipo,
            formatoData: m.formatoData,
            positivoEhGasto: m.positivoEhGasto,
          );
    }
    if (mounted) context.push(Rotas.importarRevisar);
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(importacaoProvider);
    final linhas = estado.csv;
    final m = estado.mapeamento;
    if (linhas == null || m == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mapear colunas')),
        body: const Center(child: Text('Escolha um arquivo primeiro.')),
      );
    }
    final ctl = ref.read(importacaoProvider.notifier);
    final salvos = ref.watch(mapeamentosCsvProvider).ou;
    final tema = Theme.of(context);
    final colunas = linhas.map((l) => l.length).reduce((a, b) => a > b ? a : b);
    final previa = ctl.previaCsv();
    final primeira = previa.transacoes.isEmpty ? null : previa.transacoes.first;

    DropdownButtonFormField<int?> seletor(
      String rotulo,
      int? valor,
      ValueChanged<int?> onChanged, {
      bool opcional = false,
    }) =>
        DropdownButtonFormField<int?>(
          key: ValueKey('$rotulo-$valor-${m.temCabecalho}'),
          initialValue: valor,
          isExpanded: true,
          decoration: InputDecoration(labelText: rotulo),
          items: [
            if (opcional) const DropdownMenuItem<int?>(value: null, child: Text('Não tem')),
            for (var i = 0; i < colunas; i++)
              DropdownMenuItem<int?>(
                value: i,
                child: Text(_rotuloColuna(linhas, m, i), overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: onChanged,
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Mapear colunas do CSV')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              children: [
                Text('Arquivo: ${estado.nomeArquivo ?? ''}',
                    style: tema.textTheme.bodySmall?.copyWith(color: tema.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 10),
                Card(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(8),
                    child: DataTable(
                      headingRowHeight: 40,
                      dataRowMinHeight: 36,
                      dataRowMaxHeight: 44,
                      columns: [
                        for (var i = 0; i < colunas; i++)
                          DataColumn(label: Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.w700))),
                      ],
                      rows: [
                        for (final l in linhas.take(6))
                          DataRow(cells: [
                            for (var i = 0; i < colunas; i++)
                              DataCell(Text(
                                i < l.length ? l[i] : '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )),
                          ]),
                      ],
                    ),
                  ),
                ),
                if (salvos.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Mapeamentos salvos', style: tema.textTheme.labelLarge),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final s in salvos)
                        ActionChip(
                          label: Text(s.nome),
                          avatar: const Icon(Icons.bookmark_rounded, size: 18),
                          onPressed: () {
                            ctl.trocarSeparador(s.separador);
                            ctl.definirMapeamento(MapeamentoCsv(
                              colunaData: s.colunaData,
                              colunaDescricao: s.colunaDescricao,
                              colunaValor: s.colunaValor,
                              colunaTipo: s.colunaTipo,
                              formatoData: s.formatoData,
                              separador: s.separador,
                              temCabecalho: s.temCabecalho,
                              positivoEhGasto: s.positivoEhGasto,
                            ));
                            _nomeBanco.text = s.nome;
                          },
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 18),
                seletor('Coluna da data', m.colunaData,
                    (v) => ctl.definirMapeamento(m.copiar(colunaData: v))),
                const SizedBox(height: 12),
                seletor('Coluna da descrição', m.colunaDescricao,
                    (v) => ctl.definirMapeamento(m.copiar(colunaDescricao: v))),
                const SizedBox(height: 12),
                seletor('Coluna do valor', m.colunaValor,
                    (v) => ctl.definirMapeamento(m.copiar(colunaValor: v))),
                const SizedBox(height: 12),
                seletor(
                  'Coluna do tipo (débito/crédito), se houver',
                  m.colunaTipo,
                  (v) => ctl.definirMapeamento(m.copiar(colunaTipo: () => v)),
                  opcional: true,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        key: ValueKey('fmt-${m.formatoData}'),
                        initialValue: m.formatoData,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Formato da data'),
                        items: [
                          for (final f in formatosDeData) DropdownMenuItem(value: f, child: Text(f)),
                        ],
                        onChanged: (v) => ctl.definirMapeamento(m.copiar(formatoData: v)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        key: ValueKey('sep-${m.separador}'),
                        initialValue: m.separador,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Separador'),
                        items: const [
                          DropdownMenuItem(value: ';', child: Text('Ponto e vírgula ;')),
                          DropdownMenuItem(value: ',', child: Text('Vírgula ,')),
                          DropdownMenuItem(value: '\t', child: Text('Tabulação')),
                        ],
                        onChanged: (v) => ctl.trocarSeparador(v!),
                      ),
                    ),
                  ],
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: m.temCabecalho,
                  onChanged: (v) => ctl.definirMapeamento(m.copiar(temCabecalho: v)),
                  title: const Text('A primeira linha é o cabeçalho'),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: m.positivoEhGasto,
                  onChanged: (v) => ctl.definirMapeamento(m.copiar(positivoEhGasto: v)),
                  title: const Text('Valores positivos são gastos'),
                  subtitle: const Text('Ligue para fatura de cartão (compras vêm positivas).'),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: tema.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${previa.transacoes.length} transações lidas'
                          '${previa.ignoradas > 0 ? ' · ${previa.ignoradas} linhas ignoradas' : ''}',
                          style: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      if (primeira != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Ex.: ${FormatoData.dia(primeira.data)} · ${primeira.descricao} · '
                            '${Moeda.comSinal(primeira.valor)}',
                            style: tema.textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nomeBanco,
                  decoration: const InputDecoration(
                    labelText: 'Salvar este mapeamento como (nome do banco)',
                    prefixIcon: Icon(Icons.bookmark_add_outlined),
                    helperText: 'Opcional: na próxima vez é só tocar no nome.',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: SafeArea(
              top: false,
              child: FilledButton(
                onPressed: previa.transacoes.isEmpty || _continuando ? null : _continuar,
                child: const Text('Continuar para a revisão'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
