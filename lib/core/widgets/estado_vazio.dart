import 'package:flutter/material.dart';

/// Estado vazio amigável, usado por toda tela sem dados.
class EstadoVazio extends StatelessWidget {
  const EstadoVazio({
    super.key,
    required this.icone,
    required this.titulo,
    this.mensagem,
    this.acao,
    this.onAcao,
  });

  final IconData icone;
  final String titulo;
  final String? mensagem;

  /// Botão opcional (ex.: "Cadastrar cartão").
  final String? acao;
  final VoidCallback? onAcao;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: tema.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icone, size: 32, color: tema.colorScheme.onPrimaryContainer),
            ),
            const SizedBox(height: 20),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: tema.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (mensagem != null) ...[
              const SizedBox(height: 8),
              Text(
                mensagem!,
                textAlign: TextAlign.center,
                style: tema.textTheme.bodyMedium?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (acao != null) ...[
              const SizedBox(height: 20),
              FilledButton.tonal(
                style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
                onPressed: onAcao,
                child: Text(acao!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
