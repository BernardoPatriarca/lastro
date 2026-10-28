import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/estado_vazio.dart';
import '../../core/widgets/seletor_mes.dart';
import '../../core/widgets/valor_monetario.dart';
import '../../data/banco.dart';
import '../../data/derivados.dart';
import '../../domain/datas.dart';
import 'filtro_lancamentos.dart';
import 'filtros_sheet.dart';
import 'lancamento_acoes.dart';
import 'lancamento_util.dart';
import 'pendentes_secao.dart';

class _CabecalhoDia {
  const _CabecalhoDia(this.data, this.total);
  final DateTime data;
  final int total;
}

/// Agrupa por dia (a lista já vem ordenada do mais recente para o mais antigo).
List<Object> agruparPorDia(List<Lancamento> lancs) {
  final saida = <Object>[];
  var i = 0;
  while (i < lancs.length) {
    final dia = lancs[i].data;
    var fim = i;
    var total = 0;
    while (fim < lancs.length && mesmoDia(lancs[fim].data, dia)) {
      total += contribuicaoDoDia(lancs[fim]);
      fim++;
    }
    saida.add(_CabecalhoDia(dia, total));
    saida.addAll(lancs.getRange(i, fim));
    i = fim;
  }
  return saida;
}

final _entradasProvider = Provider<List<Object>>(
  (ref) => agruparPorDia(ref.watch(lancamentosFiltradosProvider)),
);

class LancamentosPage extends ConsumerStatefulWidget {
  const LancamentosPage({super.key});

  @override
  ConsumerState<LancamentosPage> createState() => _LancamentosPageState();
}

class _LancamentosPageState extends ConsumerState<LancamentosPage> {
  bool _buscando = false;
  final _busca = TextEditingController();

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtro = ref.watch(filtroLancamentosProvider);
    final entradas = ref.watch(_entradasProvider);
    final totais = ref.watch(totaisDoMesProvider);

    return Scaffold(
      appBar: AppBar(
        title: _buscando
            ? TextField(
                controller: _busca,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Buscar por descrição',
                  border: InputBorder.none,
                  filled: false,
                ),
                onChanged: ref.read(filtroLancamentosProvider.notifier).busca,
              )
            : const Text('Lançamentos'),
        actions: [
          IconButton(
            tooltip: _buscando ? 'Fechar busca' : 'Buscar',
            icon: Icon(_buscando ? Icons.close_rounded : Icons.search_rounded),
            onPressed: () {
              setState(() => _buscando = !_buscando);
              if (!_buscando) {
                _busca.clear();
                ref.read(filtroLancamentosProvider.notifier).busca('');
              }
            },
          ),
          IconButton(
            tooltip: 'Filtros',
            onPressed: () => abrirFiltros(context, ref),
            icon: Badge(
              isLabelVisible: filtro.quantidade > 0,
              label: Text('${filtro.quantidade}'),
              child: const Icon(Icons.tune_rounded),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SeletorMes()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  _Resumo('Ganhos', totais.ganhos, positivo: true),
                  const SizedBox(width: 10),
                  _Resumo('Gastos', totais.gastos, positivo: false),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: PendentesSecao()),
          if (entradas.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EstadoVazio(
                icone: filtro.ativo
                    ? Icons.search_off_rounded
                    : Icons.receipt_long_rounded,
                titulo: filtro.ativo
                    ? 'Nada encontrado com esses filtros'
                    : 'Nenhum lançamento neste mês',
                mensagem: filtro.ativo
                    ? 'Tente limpar a busca ou os filtros.'
                    : 'Toque em + para adicionar.',
              ),
            )
          else
            SliverList.builder(
              itemCount: entradas.length,
              itemBuilder: (context, i) {
                final e = entradas[i];
                if (e is _CabecalhoDia) return _Cabecalho(e);
                final l = e as Lancamento;
                return LinhaLancamentoDispensavel(
                  key: ValueKey(l.id),
                  lancamento: l,
                );
              },
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),
    );
  }
}

class _Resumo extends StatelessWidget {
  const _Resumo(this.rotulo, this.valor, {required this.positivo});
  final String rotulo;
  final int valor;
  final bool positivo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: tema.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(rotulo,
                style: tema.textTheme.labelMedium
                    ?.copyWith(color: tema.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 2),
            ValorMonetario(
              positivo ? valor : -valor,
              colorirPorSinal: valor != 0,
              mostrarMais: true,
              estilo: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho(this.dia);
  final _CabecalhoDia dia;

  static String rotuloDia(DateTime d) {
    final hoje = soData(DateTime.now());
    if (mesmoDia(d, hoje)) return 'Hoje';
    if (mesmoDia(d, hoje.subtract(const Duration(days: 1)))) return 'Ontem';
    final t = DateFormat("EEEE, dd 'de' MMMM", 'pt_BR').format(d);
    return t[0].toUpperCase() + t.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              rotuloDia(dia.data),
              style: tema.textTheme.labelLarge
                  ?.copyWith(color: tema.colorScheme.onSurfaceVariant),
            ),
          ),
          if (dia.total != 0)
            ValorMonetario(
              dia.total,
              colorirPorSinal: true,
              mostrarMais: true,
              estilo: tema.textTheme.labelMedium,
            ),
        ],
      ),
    );
  }
}
