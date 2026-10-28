import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';

/// Menu "Mais": atalhos para as áreas secundárias do app.
class MaisPage extends StatelessWidget {
  const MaisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mais')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _Item(
            icone: Icons.account_balance_wallet_rounded,
            titulo: 'Contas',
            subtitulo: 'Saldos, ajuste de saldo e transferências',
            onTap: () => context.push(Rotas.contas),
          ),
          _Item(
            icone: Icons.event_repeat_rounded,
            titulo: 'Compromissos',
            subtitulo: 'Gastos fixos, parcelados e receitas recorrentes',
            onTap: () => context.push(Rotas.compromissos),
          ),
          _Item(
            icone: Icons.pie_chart_rounded,
            titulo: 'Orçamento',
            subtitulo: 'Limite mensal por categoria, com alertas de estouro',
            onTap: () => context.push(Rotas.orcamento),
          ),
          _Item(
            icone: Icons.bar_chart_rounded,
            titulo: 'Relatórios',
            subtitulo: 'Evolução, comparativos, médias e fixos × variáveis',
            onTap: () => context.push(Rotas.relatorios),
          ),
          _Item(
            icone: Icons.upload_file_rounded,
            titulo: 'Importar extrato',
            subtitulo: 'OFX ou CSV do banco, com revisão antes de lançar',
            onTap: () => context.push(Rotas.importar),
          ),
          _Item(
            icone: Icons.category_rounded,
            titulo: 'Categorias',
            subtitulo: 'Categorias, subcategorias e regras de categorização',
            onTap: () => context.push(Rotas.categorias),
          ),
          _Item(
            icone: Icons.settings_rounded,
            titulo: 'Configurações',
            subtitulo: 'Crédito seguro, tema, segurança e privacidade',
            onTap: () => context.push(Rotas.configuracoes),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.icone,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });
  final IconData icone;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tema.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icone, color: tema.colorScheme.onPrimaryContainer),
          ),
          title: Text(titulo,
              style: tema.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          subtitle: Text(subtitulo),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: onTap,
        ),
      ),
    );
  }
}
