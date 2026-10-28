import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../data/derivados.dart';
import '../../data/providers.dart';
import '../lancamentos/lancamento_acoes.dart';
import 'importacao_controller.dart';

/// Importar extrato: escolhe o destino (conta ou fatura de cartão) e o arquivo
/// (OFX ou CSV).
class ImportarPage extends ConsumerStatefulWidget {
  const ImportarPage({super.key});

  @override
  ConsumerState<ImportarPage> createState() => _ImportarPageState();
}

class _ImportarPageState extends ConsumerState<ImportarPage> {
  bool _lendo = false;

  @override
  void initState() {
    super.initState();
    // Começa sempre do zero.
    Future.microtask(() => ref.read(importacaoProvider.notifier).limpar());
  }

  /// Destino efetivo: o escolhido ou, se ainda não escolheu, o primeiro.
  int? _destinoEfetivo(EstadoImportacao e) {
    if (e.destino == TipoDestino.conta) {
      final contas = ref.read(contasAtivasProvider);
      return contas.any((c) => c.id == e.contaId)
          ? e.contaId
          : (contas.isNotEmpty ? contas.first.id : null);
    }
    final cartoes = [for (final c in ref.read(cartoesProvider).ou) if (c.ativo) c];
    return cartoes.any((c) => c.id == e.cartaoId)
        ? e.cartaoId
        : (cartoes.isNotEmpty ? cartoes.first.id : null);
  }

  Future<void> _escolher() async {
    final ctl = ref.read(importacaoProvider.notifier);
    ctl.definirDestino(
      ref.read(importacaoProvider).destino,
      _destinoEfetivo(ref.read(importacaoProvider)),
    );
    final estado = ref.read(importacaoProvider);
    if (estado.destinoId == null) {
      mostrarAviso(context, estado.destino == TipoDestino.conta
          ? 'Escolha a conta de destino.'
          : 'Escolha o cartão da fatura.');
      return;
    }
    final arquivo = await ref.read(seletorDeArquivoProvider)();
    if (arquivo == null || !mounted) return;

    setState(() => _lendo = true);
    final formato = await ctl.carregar(arquivo);
    if (!mounted) return;
    setState(() => _lendo = false);

    switch (formato) {
      case FormatoArquivo.invalido:
        mostrarAviso(context, 'Não consegui ler transações deste arquivo. '
            'Use um extrato OFX ou CSV do seu banco.');
      case FormatoArquivo.csv:
        context.push(Rotas.importarMapear);
      case FormatoArquivo.ofx:
        final e = ref.read(importacaoProvider);
        final cartaoNoArquivo = e.arquivoEhCartao;
        final destinoCartao = e.destino == TipoDestino.cartao;
        if (cartaoNoArquivo != destinoCartao) {
          final seguir = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Tipo de arquivo diferente'),
              content: Text(cartaoNoArquivo
                  ? 'Este arquivo parece ser de um cartão de crédito, mas você '
                      'escolheu uma conta. Continuar mesmo assim?'
                  : 'Este arquivo parece ser extrato de conta, mas você escolheu '
                      'um cartão. Continuar mesmo assim?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Voltar')),
                FilledButton(
                  style: FilledButton.styleFrom(minimumSize: const Size(110, 44)),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Continuar'),
                ),
              ],
            ),
          );
          if (seguir != true || !mounted) return;
        }
        context.push(Rotas.importarRevisar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(importacaoProvider);
    final contas = ref.watch(contasAtivasProvider);
    final cartoes = [for (final c in ref.watch(cartoesProvider).ou) if (c.ativo) c];
    final ctl = ref.read(importacaoProvider.notifier);
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Importar extrato')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: tema.colorScheme.secondaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.upload_file_rounded, size: 34, color: tema.colorScheme.secondary),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Baixe o extrato no app ou site do seu banco (OFX é o ideal; '
                    'CSV também funciona) e traga para cá. Você revisa tudo antes '
                    'de lançar.',
                    style: tema.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Para onde vão os lançamentos?',
              style: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          SegmentedButton<TipoDestino>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: TipoDestino.conta,
                label: Text('Conta'),
                icon: Icon(Icons.account_balance_rounded),
              ),
              ButtonSegment(
                value: TipoDestino.cartao,
                label: Text('Fatura de cartão'),
                icon: Icon(Icons.credit_card_rounded),
              ),
            ],
            selected: {estado.destino},
            onSelectionChanged: (s) => ctl.definirDestino(
              s.first,
              s.first == TipoDestino.conta
                  ? (contas.isNotEmpty ? contas.first.id : null)
                  : (cartoes.isNotEmpty ? cartoes.first.id : null),
            ),
          ),
          const SizedBox(height: 14),
          if (estado.destino == TipoDestino.conta)
            contas.isEmpty
                ? _SemDestino('Você ainda não tem conta.', 'Criar conta', () => context.push(Rotas.novaConta))
                : DropdownButtonFormField<int>(
                    key: ValueKey('conta-${estado.contaId}'),
                    initialValue: _destinoEfetivo(estado),
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Conta',
                      prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                    ),
                    items: [for (final c in contas) DropdownMenuItem(value: c.id, child: Text(c.nome))],
                    onChanged: (v) => ctl.definirDestino(TipoDestino.conta, v),
                  )
          else
            cartoes.isEmpty
                ? _SemDestino('Você ainda não tem cartão.', 'Cadastrar cartão', () => context.push(Rotas.novoCartao))
                : DropdownButtonFormField<int>(
                    key: ValueKey('cartao-${estado.cartaoId}'),
                    initialValue: _destinoEfetivo(estado),
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Cartão',
                      prefixIcon: Icon(Icons.credit_card_rounded),
                    ),
                    items: [for (final c in cartoes) DropdownMenuItem(value: c.id, child: Text(c.nome))],
                    onChanged: (v) => ctl.definirDestino(TipoDestino.cartao, v),
                  ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: _lendo ? null : _escolher,
            icon: _lendo
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Icon(Icons.folder_open_rounded),
            label: Text(_lendo ? 'Lendo arquivo…' : 'Escolher arquivo (OFX ou CSV)'),
          ),
          const SizedBox(height: 20),
          Text(
            'Dica: transações já importadas antes são reconhecidas e ficam '
            'desmarcadas, então não tem problema reimportar um período.',
            style: tema.textTheme.bodySmall?.copyWith(color: tema.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _SemDestino extends StatelessWidget {
  const _SemDestino(this.texto, this.acao, this.onAcao);
  final String texto;
  final String acao;
  final VoidCallback onAcao;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(child: Text(texto)),
          TextButton(onPressed: onAcao, child: Text(acao)),
        ],
      );
}
