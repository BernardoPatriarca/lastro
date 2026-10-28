import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/valor_monetario.dart';
import '../../data/banco.dart';
import '../../data/derivados.dart';
import '../../domain/enums.dart';
import '../categorias/seletor_categoria.dart';
import 'lancamento_util.dart';

/// Linha de lançamento: ícone da categoria, descrição, detalhes e valor.
class LancamentoTile extends ConsumerWidget {
  const LancamentoTile({super.key, required this.lancamento, this.onTap});

  final Lancamento lancamento;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = lancamento;
    final tema = Theme.of(context);
    final categoria = l.categoriaId == null
        ? null
        : ref.watch(categoriasPorIdProvider.select((m) => m[l.categoriaId]));
    final conta = l.contaId == null
        ? null
        : ref.watch(contasPorIdProvider.select((m) => m[l.contaId]));
    final cartao = l.cartaoId == null
        ? null
        : ref.watch(cartoesPorIdProvider.select((m) => m[l.cartaoId]));

    final titulo = l.descricao.isNotEmpty
        ? l.descricao
        : (categoria?.nome ?? l.tipo.rotulo);
    final detalhes = [
      if (l.descricao.isNotEmpty && categoria != null) categoria.nome,
      if (l.tipo == TipoLancamento.gasto && l.formaPagamento != null)
        l.formaPagamento!.rotulo
      else if (l.tipo != TipoLancamento.gasto && l.tipo != TipoLancamento.ganho)
        l.tipo.rotulo,
      if (cartao != null) cartao.nome else if (conta != null) conta.nome,
    ].join(' · ');

    final valor = valorExibido(l);
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: categoria != null
          ? IconeCategoria(categoria: categoria)
          : IconeCategoria(icone: iconeDoTipo(l.tipo)),
      title: Text(titulo, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        detalhes,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: tema.textTheme.bodySmall
            ?.copyWith(color: tema.colorScheme.onSurfaceVariant),
      ),
      trailing: ValorMonetario(
        valor,
        colorirPorSinal: !ehNeutro(l),
        mostrarMais: !ehNeutro(l),
        estilo: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
