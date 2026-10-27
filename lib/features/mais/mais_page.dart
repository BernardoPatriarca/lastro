import 'package:flutter/material.dart';

import '../../core/widgets/estado_vazio.dart';

class MaisPage extends StatelessWidget {
  const MaisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mais')),
      body: const EstadoVazio(
        icone: Icons.menu_rounded,
        titulo: 'Em construção',
        mensagem: 'Compromissos, contas, categorias, importação e configurações ficam aqui.',
      ),
    );
  }
}
