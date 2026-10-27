import 'package:flutter/material.dart';

import '../../core/widgets/estado_vazio.dart';

class InvestimentosPage extends StatelessWidget {
  const InvestimentosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Investimentos')),
      body: const EstadoVazio(
        icone: Icons.trending_up_rounded,
        titulo: 'Nenhum investimento cadastrado',
        mensagem: 'Reserva, CDB, tesouro e outros chegam na V2.',
      ),
    );
  }
}
