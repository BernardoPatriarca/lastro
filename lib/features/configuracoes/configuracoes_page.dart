import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/enums.dart';
import '../login/auth_controller.dart';
import '../lancamentos/lancamento_acoes.dart';

/// Configurações: crédito seguro, aparência, privacidade e segurança.
class ConfiguracoesPage extends ConsumerWidget {
  const ConfiguracoesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(ajustesProvider);
    final definir = ref.read(definirAjusteProvider);
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        children: [
          const _Secao('Crédito seguro'),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Text('Compras parceladas',
                      style: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                ),
                RadioGroup<ModoParcelados>(
                  groupValue: a.modoParcelados,
                  onChanged: (v) => definir('modo_parcelados', v!.name),
                  child: const Column(
                    children: [
                      RadioListTile<ModoParcelados>(
                        value: ModoParcelados.rigido,
                        title: Text('Rígido'),
                        subtitle: Text(
                          'Desconta todo o valor ainda não pago, inclusive as parcelas futuras.',
                        ),
                      ),
                      RadioListTile<ModoParcelados>(
                        value: ModoParcelados.parcela,
                        title: Text('Por parcela'),
                        subtitle: Text(
                          'Desconta só faturas abertas e fechadas; as parcelas futuras aparecem como informação.',
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                SwitchListTile(
                  value: a.descontarFixos,
                  onChanged: (v) => definir('descontar_fixos', '$v'),
                  title: const Text('Descontar contas fixas'),
                  subtitle: const Text(
                    'Subtrai as contas pendentes que vencem até o vencimento da próxima fatura.',
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Text('Quando uma compra estourar',
                      style: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                ),
                RadioGroup<ComportamentoEstouro>(
                  groupValue: a.comportamentoEstouro,
                  onChanged: (v) => definir('comportamento_estouro', v!.name),
                  child: const Column(
                    children: [
                      RadioListTile<ComportamentoEstouro>(
                        value: ComportamentoEstouro.avisar,
                        title: Text('Só avisar'),
                        subtitle: Text('Mostra o aviso em vermelho e deixa lançar.'),
                      ),
                      RadioListTile<ComportamentoEstouro>(
                        value: ComportamentoEstouro.confirmar,
                        title: Text('Pedir confirmação'),
                        subtitle: Text('Pergunta se quer lançar mesmo assim.'),
                      ),
                      RadioListTile<ComportamentoEstouro>(
                        value: ComportamentoEstouro.bloquear,
                        title: Text('Bloquear'),
                        subtitle: Text('Não deixa lançar compra que passa do saldo.'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
          const _Secao('Aparência e privacidade'),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: SegmentedButton<String>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: 'dark', label: Text('Escuro'), icon: Icon(Icons.dark_mode_rounded)),
                      ButtonSegment(value: 'light', label: Text('Claro'), icon: Icon(Icons.light_mode_rounded)),
                      ButtonSegment(value: 'system', label: Text('Auto'), icon: Icon(Icons.brightness_auto_rounded)),
                    ],
                    selected: {a.tema},
                    onSelectionChanged: (s) => definir('tema', s.first),
                  ),
                ),
                SwitchListTile(
                  value: a.ocultarValores,
                  onChanged: (v) => definir('ocultar_valores', '$v'),
                  secondary: const Icon(Icons.visibility_off_outlined),
                  title: const Text('Ocultar valores'),
                  subtitle: const Text('Mostra R\$ ••• no lugar dos valores.'),
                ),
              ],
            ),
          ),
          const _Secao('Segurança'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: a.biometria,
                  onChanged: (v) => _alternarBiometria(context, ref, v),
                  secondary: const Icon(Icons.fingerprint_rounded),
                  title: const Text('Entrar com biometria'),
                  subtitle: const Text('Digital ou rosto, quando o aparelho tiver.'),
                ),
                ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: const Text('Bloquear após'),
                  subtitle: const Text('Tempo fora do app antes de pedir a senha de novo.'),
                  trailing: DropdownButton<int>(
                    value: const [0, 1, 2, 5, 10, 15, 30].contains(a.bloqueioMinutos)
                        ? a.bloqueioMinutos
                        : 2,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Na hora')),
                      DropdownMenuItem(value: 1, child: Text('1 min')),
                      DropdownMenuItem(value: 2, child: Text('2 min')),
                      DropdownMenuItem(value: 5, child: Text('5 min')),
                      DropdownMenuItem(value: 10, child: Text('10 min')),
                      DropdownMenuItem(value: 15, child: Text('15 min')),
                      DropdownMenuItem(value: 30, child: Text('30 min')),
                    ],
                    onChanged: (v) => definir('bloqueio_minutos', '$v'),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.password_rounded),
                  title: const Text('Trocar senha'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _trocarSenha(context, ref),
                ),
                ListTile(
                  leading: const Icon(Icons.lock_rounded),
                  title: const Text('Bloquear agora'),
                  onTap: () => ref.read(authProvider.notifier).bloquear(),
                ),
              ],
            ),
          ),
          ..._extras(context, ref),
        ],
      ),
    );
  }

  /// Ponto de extensão: backup e restauração entram aqui (Etapa 10).
  List<Widget> _extras(BuildContext context, WidgetRef ref) => const [];

  Future<void> _alternarBiometria(BuildContext context, WidgetRef ref, bool ligar) async {
    final definir = ref.read(definirAjusteProvider);
    if (!ligar) {
      await definir('biometria', 'false');
      return;
    }
    final bio = ref.read(autenticadorBiometricoProvider);
    if (!await bio.disponivel()) {
      if (context.mounted) {
        mostrarAviso(context, 'Este aparelho não tem biometria cadastrada.');
      }
      return;
    }
    final ok = await bio.autenticar('Confirme sua biometria para ativá-la');
    if (ok) await definir('biometria', 'true');
  }

  Future<void> _trocarSenha(BuildContext context, WidgetRef ref) async {
    final atual = TextEditingController();
    final nova = TextEditingController();
    final confirma = TextEditingController();
    String? erro;
    final trocou = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Trocar senha'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: atual,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha atual'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nova,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nova senha (mín. 6)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirma,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirme a nova senha'),
              ),
              if (erro != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(erro!, style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
              onPressed: () async {
                if (nova.text.length < 6) {
                  setSt(() => erro = 'A nova senha precisa ter pelo menos 6 caracteres.');
                  return;
                }
                if (nova.text != confirma.text) {
                  setSt(() => erro = 'A confirmação não confere.');
                  return;
                }
                final ok = await ref
                    .read(servicoSenhaProvider)
                    .trocarSenha(atual.text, nova.text);
                if (!ctx.mounted) return;
                if (ok) {
                  Navigator.pop(ctx, true);
                } else {
                  setSt(() => erro = 'Senha atual incorreta (ou muitas tentativas).');
                }
              },
              child: const Text('Trocar'),
            ),
          ],
        ),
      ),
    );
    atual.dispose();
    nova.dispose();
    confirma.dispose();
    if (trocou == true && context.mounted) mostrarAviso(context, 'Senha alterada');
  }
}

class _Secao extends StatelessWidget {
  const _Secao(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
        child: Text(
          texto,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.secondary,
              ),
        ),
      );
}
