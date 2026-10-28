import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/formatadores/data.dart';
import '../../data/providers.dart';
import '../../data/servicos/servicos.dart';
import '../../domain/backup.dart';
import '../importacao/importacao_controller.dart';
import '../lancamentos/lancamento_acoes.dart';

/// Grava [conteudo] num arquivo temporário e abre a folha de compartilhar
/// (salvar no Drive, enviar por e-mail etc.). Os testes trocam por um falso.
final salvarECompartilharProvider =
    Provider<Future<void> Function(String nome, String conteudo)>(
  (ref) => (nome, conteudo) async {
    final dir = await getTemporaryDirectory();
    final arquivo = File('${dir.path}/$nome');
    await arquivo.writeAsString(conteudo, flush: true);
    await SharePlus.instance.share(ShareParams(
      files: [XFile(arquivo.path, mimeType: 'application/json')],
      subject: 'Backup do Lastro',
      title: 'Backup do Lastro',
    ));
  },
);

/// Há quantos dias o último backup foi feito (`null` se nunca).
int? diasDesdeUltimoBackup(DateTime? ultimo, DateTime agora) =>
    ultimo == null ? null : agora.difference(ultimo).inDays;

/// Passou de [limiteDias] ou nunca fez backup.
bool backupAtrasado(DateTime? ultimo, DateTime agora, {int limiteDias = 30}) {
  final d = diasDesdeUltimoBackup(ultimo, agora);
  return d == null || d >= limiteDias;
}

String _quando(DateTime d) =>
    '${FormatoData.dia(d)} às ${DateFormat.Hm('pt_BR').format(d)}';

/// Lembrete no topo das configurações quando o backup está atrasado.
class LembreteBackup extends ConsumerWidget {
  const LembreteBackup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ultimo = ref.watch(ajustesProvider.select((a) => a.ultimoBackup));
    if (!backupAtrasado(ultimo, DateTime.now())) return const SizedBox.shrink();
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tema.colorScheme.errorContainer.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: tema.colorScheme.error.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.cloud_off_rounded, color: tema.colorScheme.error),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    ultimo == null
                        ? 'Você ainda não fez backup. Seus dados só existem neste celular.'
                        : 'Seu último backup foi em ${FormatoData.dia(ultimo)}. '
                            'Faça um novo para não perder nada.',
                    style: tema.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => exportarBackup(context, ref),
                child: const Text('Fazer agora'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Seção "Backup" das configurações: exportar, restaurar e data do último.
class BackupSecao extends ConsumerWidget {
  const BackupSecao({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ultimo = ref.watch(ajustesProvider.select((a) => a.ultimoBackup));
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.ios_share_rounded),
            title: const Text('Exportar backup'),
            subtitle: Text(
              ultimo == null
                  ? 'Nenhum backup feito ainda'
                  : 'Último backup: ${_quando(ultimo)}',
            ),
            onTap: () => exportarBackup(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.settings_backup_restore_rounded),
            title: const Text('Restaurar backup'),
            subtitle: const Text('Substitui todos os dados por um backup'),
            onTap: () => restaurarBackup(context, ref),
          ),
        ],
      ),
    );
  }
}

/// Gera o backup (JSON) e abre o compartilhar.
Future<void> exportarBackup(BuildContext context, WidgetRef ref) async {
  try {
    final agora = DateTime.now();
    final backup = await ref.read(servicoBackupProvider).exportar(agora: agora);
    final nome = 'lastro-backup-${DateFormat('yyyyMMdd-HHmm').format(agora)}.json';
    await ref.read(salvarECompartilharProvider)(nome, backup.paraJson());
    await ref.read(definirAjusteProvider)('ultimo_backup', agora.toIso8601String());
    if (context.mounted) mostrarAviso(context, 'Backup gerado');
  } on Object catch (e) {
    if (context.mounted) mostrarAviso(context, 'Não foi possível gerar o backup: $e');
  }
}

/// Escolhe um arquivo, valida, mostra o resumo e pede confirmação antes de
/// substituir tudo.
Future<void> restaurarBackup(BuildContext context, WidgetRef ref) async {
  final arquivo = await ref.read(seletorDeArquivoProvider)();
  if (arquivo == null || !context.mounted) return;

  final servico = ref.read(servicoBackupProvider);
  final Backup backup;
  try {
    backup = servico.ler(utf8.decode(arquivo.bytes, allowMalformed: true));
  } on BackupInvalido catch (e) {
    mostrarAviso(context, e.mensagem);
    return;
  }

  final r = backup.resumir();
  final periodo = r.primeiroLancamento == null
      ? 'sem lançamentos'
      : '${FormatoData.dia(r.primeiroLancamento!)} a ${FormatoData.dia(r.ultimoLancamento!)}';
  final confirmou = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: Icon(Icons.warning_amber_rounded, color: Theme.of(ctx).colorScheme.error),
      title: const Text('Restaurar este backup?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Backup de ${_quando(r.exportadoEm)}'),
          const SizedBox(height: 10),
          Text('• ${r.lancamentos} lançamentos ($periodo)'),
          Text('• ${r.contas} contas · ${r.cartoes} cartões'),
          Text('• ${r.categorias} categorias · ${r.compromissos} compromissos'),
          const SizedBox(height: 14),
          Text(
            'Tudo que está no app agora será SUBSTITUÍDO por estes dados. '
            'Isso não pode ser desfeito.',
            style: TextStyle(
              color: Theme.of(ctx).colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size(110, 44),
            backgroundColor: Theme.of(ctx).colorScheme.error,
            foregroundColor: Theme.of(ctx).colorScheme.onError,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Restaurar'),
        ),
      ],
    ),
  );
  if (confirmou != true || !context.mounted) return;

  try {
    await servico.restaurar(backup);
    if (context.mounted) mostrarAviso(context, 'Backup restaurado');
  } on Object catch (e) {
    if (context.mounted) {
      mostrarAviso(context, 'Não foi possível restaurar (nada foi alterado): $e');
    }
  }
}
