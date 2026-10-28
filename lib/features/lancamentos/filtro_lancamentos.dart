import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/banco.dart';
import '../../data/derivados.dart';
import '../../domain/enums.dart';
import '../../domain/texto.dart';

/// Filtros da lista de lançamentos (período = mês selecionado).
class FiltroLancamentos {
  const FiltroLancamentos({
    this.tipos = const {},
    this.categoriaId,
    this.forma,
    this.contaId,
    this.cartaoId,
    this.busca = '',
  });

  final Set<TipoLancamento> tipos;
  final int? categoriaId;
  final FormaPagamento? forma;
  final int? contaId;
  final int? cartaoId;
  final String busca;

  /// Quantos filtros (fora a busca) estão ligados.
  int get quantidade => (tipos.isEmpty ? 0 : 1) +
      (categoriaId == null ? 0 : 1) +
      (forma == null ? 0 : 1) +
      (contaId == null ? 0 : 1) +
      (cartaoId == null ? 0 : 1);

  bool get ativo => quantidade > 0 || busca.isNotEmpty;

  FiltroLancamentos copiar({
    Set<TipoLancamento>? tipos,
    int? Function()? categoriaId,
    FormaPagamento? Function()? forma,
    int? Function()? contaId,
    int? Function()? cartaoId,
    String? busca,
  }) =>
      FiltroLancamentos(
        tipos: tipos ?? this.tipos,
        categoriaId: categoriaId != null ? categoriaId() : this.categoriaId,
        forma: forma != null ? forma() : this.forma,
        contaId: contaId != null ? contaId() : this.contaId,
        cartaoId: cartaoId != null ? cartaoId() : this.cartaoId,
        busca: busca ?? this.busca,
      );

  /// Aplica o filtro a [l]. [categoriaDe] resolve o nome para a busca textual.
  bool aceita(Lancamento l, Map<int, Categoria> categorias) {
    if (tipos.isNotEmpty && !tipos.contains(l.tipo)) return false;
    if (categoriaId != null) {
      final c = l.categoriaId == null ? null : categorias[l.categoriaId];
      // Filtrar pela categoria-pai inclui as subcategorias.
      if (l.categoriaId != categoriaId && c?.categoriaPaiId != categoriaId) {
        return false;
      }
    }
    if (forma != null && l.formaPagamento != forma) return false;
    if (contaId != null && l.contaId != contaId && l.contaDestinoId != contaId) {
      return false;
    }
    if (cartaoId != null && l.cartaoId != cartaoId) return false;
    if (busca.isNotEmpty) {
      final alvo = normalizarTexto(l.descricao);
      if (!alvo.contains(normalizarTexto(busca))) return false;
    }
    return true;
  }
}

class FiltroNotifier extends Notifier<FiltroLancamentos> {
  @override
  FiltroLancamentos build() => const FiltroLancamentos();

  void definir(FiltroLancamentos f) => state = f;
  void busca(String texto) => state = state.copiar(busca: texto);
  void limpar() => state = const FiltroLancamentos();
}

final filtroLancamentosProvider =
    NotifierProvider<FiltroNotifier, FiltroLancamentos>(FiltroNotifier.new);

final lancamentosFiltradosProvider = Provider<List<Lancamento>>((ref) {
  final filtro = ref.watch(filtroLancamentosProvider);
  final categorias = ref.watch(categoriasPorIdProvider);
  final doMes = ref.watch(lancamentosDoMesProvider);
  if (!filtro.ativo) return doMes;
  return [for (final l in doMes) if (filtro.aceita(l, categorias)) l];
});
