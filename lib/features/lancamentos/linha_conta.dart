import 'package:flutter/material.dart';

/// Linha de "conta" (pendente, conta do mês): ícone, título/subtítulo e, à
/// direita, o valor com um botão de ação embaixo. Não usa `ListTile` porque o
/// trailing largo estourava em telas estreitas ou com fonte grande.
class LinhaConta extends StatelessWidget {
  const LinhaConta({
    super.key,
    required this.leading,
    required this.titulo,
    required this.subtitulo,
    required this.valor,
    this.corSubtitulo,
    this.acao,
    this.onAcao,
    this.onTap,
    this.riscado = false,
  });

  final Widget leading;
  final String titulo;
  final String subtitulo;
  final Color? corSubtitulo;
  final Widget valor;
  final String? acao;
  final VoidCallback? onAcao;
  final VoidCallback? onTap;
  final bool riscado;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tema.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: riscado ? TextDecoration.lineThrough : null,
                      decorationColor: tema.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: tema.textTheme.bodySmall?.copyWith(
                      color: corSubtitulo ?? tema.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 124),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: valor,
                  ),
                  if (acao != null) ...[
                    const SizedBox(height: 6),
                    FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 34),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        textStyle: tema.textTheme.labelLarge,
                      ),
                      onPressed: onAcao,
                      child: Text(acao!),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
