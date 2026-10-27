import 'package:flutter/material.dart';

import '../../core/widgets/estado_vazio.dart';

class LancamentosPage extends StatelessWidget {
  const LancamentosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lançamentos')),
      body: const EstadoVazio(
        icone: Icons.receipt_long_rounded,
        titulo: 'Nenhum lançamento neste mês',
        mensagem: 'Toque em + para adicionar.',
      ),
    );
  }
}
