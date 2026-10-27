import 'package:flutter/material.dart';

import '../../core/widgets/estado_vazio.dart';

class CartoesPage extends StatelessWidget {
  const CartoesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cartões')),
      body: const EstadoVazio(
        icone: Icons.credit_card_rounded,
        titulo: 'Nenhum cartão cadastrado',
        mensagem: 'Cadastre um cartão para acompanhar faturas e parcelas.',
      ),
    );
  }
}
