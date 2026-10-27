import 'package:flutter/material.dart';

import '../../core/widgets/estado_vazio.dart';
import 'card_credito_seguro.dart';

/// Dashboard. Nesta etapa: só o card de destaque (vazio) e o estado vazio.
class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Início')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: const [
          CardCreditoSeguro(),
          SizedBox(height: 24),
          SizedBox(
            height: 280,
            child: EstadoVazio(
              icone: Icons.insights_rounded,
              titulo: 'Nada para mostrar ainda',
              mensagem:
                  'Cadastre uma conta e faça o primeiro lançamento — toque em + para começar.',
            ),
          ),
        ],
      ),
    );
  }
}
