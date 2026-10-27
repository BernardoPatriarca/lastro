import 'package:flutter/material.dart';

/// Provisório (Etapa 3 implementa o lançamento rápido de verdade).
void abrirLancamentoRapido(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => const Padding(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Lançamento rápido',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text('Chega na Etapa 3: gasto, ganho e transferência/aporte.'),
        ],
      ),
    ),
  );
}
