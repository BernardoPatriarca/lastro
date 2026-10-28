import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatadores/data.dart';
import '../../core/widgets/campo_valor.dart';
import '../../data/banco.dart';
import '../../data/derivados.dart';
import '../../data/providers.dart';
import '../../data/servicos/servicos.dart';
import '../../domain/datas.dart';
import '../../domain/enums.dart';
import '../categorias/seletor_categoria.dart';

/// Cadastro/edição de gasto fixo (recorrente ou parcelado) fora do cartão.
///
/// Ao editar, tipo, nº de parcelas e data da primeira ficam travados: mexer
/// neles bagunçaria as parcelas já pagas.
class CompromissoFormPage extends ConsumerStatefulWidget {
  const CompromissoFormPage({super.key, this.id});
  final int? id;

  @override
  ConsumerState<CompromissoFormPage> createState() => _CompromissoFormPageState();
}

class _CompromissoFormPageState extends ConsumerState<CompromissoFormPage> {
  final _chave = GlobalKey<FormState>();
  final _descricao = TextEditingController();
  final _valor = ControladorValor();

  Compromisso? _original;
  bool _carregando = false;
  TipoCompromisso _tipo = TipoCompromisso.recorrente;
  int _parcelas = 12;
  DateTime _inicio = soData(DateTime.now());
  FormaPagamento _forma = FormaPagamento.boleto;
  int? _contaId;
  int? _categoriaId;
  bool _ativo = true;

  bool get _edicao => widget.id != null;

  @override
  void initState() {
    super.initState();
    if (_edicao) {
      _carregando = true;
      _carregar();
    }
  }

  Future<void> _carregar() async {
    final c = await ref.read(bancoProvider).compromissosDao.compromisso(widget.id!);
    if (!mounted) return;
    if (c == null) {
      context.pop();
      return;
    }
    setState(() {
      _original = c;
      _carregando = false;
      _descricao.text = c.descricao;
      _valor.centavos = c.valor;
      _tipo = c.tipo;
      _parcelas = c.numeroParcelas ?? 12;
      _inicio = c.dataInicio;
      _forma = c.formaPagamento;
      _contaId = c.contaId;
      _categoriaId = c.categoriaId;
      _ativo = c.ativo;
    });
  }

  @override
  void dispose() {
    _descricao.dispose();
    _valor.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_chave.currentState!.validate()) return;
    final servico = ref.read(servicoCompromissoProvider);
    final contas = ref.read(contasAtivasProvider);
    final contaId = _contaId ?? (contas.isNotEmpty ? contas.first.id : null);
    final o = _original;
    if (o == null) {
      await servico.criarCompromisso(
        descricao: _descricao.text,
        valor: _valor.centavos,
        tipo: _tipo,
        dataInicio: _inicio,
        numeroParcelas: _parcelas,
        forma: _forma,
        categoriaId: _categoriaId,
        contaId: contaId,
      );
    } else {
      await servico.atualizarCompromisso(
        o,
        descricao: _descricao.text,
        valor: _valor.centavos,
        forma: _forma,
        categoriaId: _categoriaId,
        contaId: contaId,
        ativo: _ativo,
      );
    }
    if (mounted) context.pop();
  }

  Future<void> _excluir() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir compromisso?'),
        content: const Text(
          'As contas pendentes dele somem. Os pagamentos já lançados continuam '
          'na lista de lançamentos.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(80, 44)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(servicoCompromissoProvider).excluirCompromisso(_original!.id);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final contas = ref.watch(contasAtivasProvider);
    final contaValida = contas.any((c) => c.id == _contaId) ? _contaId : null;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Fechar',
          onPressed: () => context.pop(),
        ),
        title: Text(_edicao ? 'Editar gasto fixo' : 'Novo gasto fixo'),
        actions: [
          if (_edicao)
            IconButton(
              tooltip: 'Excluir',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _excluir,
            ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Form(
                key: _chave,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                        children: [
                          TextFormField(
                            controller: _descricao,
                            autofocus: !_edicao,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              labelText: 'Descrição',
                              hintText: 'Ex.: Aluguel, Internet',
                              prefixIcon: Icon(Icons.label_outline_rounded),
                            ),
                            validator: (v) =>
                                (v ?? '').trim().isEmpty ? 'Descreva o gasto' : null,
                          ),
                          const SizedBox(height: 16),
                          CampoValor(
                            controller: _valor,
                            rotulo: _tipo == TipoCompromisso.parcelado
                                ? 'Valor da parcela'
                                : 'Valor mensal',
                            validator: (_) =>
                                _valor.centavos <= 0 ? 'Informe o valor' : null,
                          ),
                          const SizedBox(height: 20),
                          IgnorePointer(
                            ignoring: _edicao,
                            child: Opacity(
                              opacity: _edicao ? 0.55 : 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SegmentedButton<TipoCompromisso>(
                                    showSelectedIcon: false,
                                    segments: const [
                                      ButtonSegment(
                                        value: TipoCompromisso.recorrente,
                                        label: Text('Recorrente'),
                                        icon: Icon(Icons.all_inclusive_rounded),
                                      ),
                                      ButtonSegment(
                                        value: TipoCompromisso.parcelado,
                                        label: Text('Parcelado'),
                                        icon: Icon(Icons.format_list_numbered_rounded),
                                      ),
                                    ],
                                    selected: {_tipo},
                                    onSelectionChanged: (s) => setState(() => _tipo = s.first),
                                  ),
                                  if (_tipo == TipoCompromisso.parcelado) ...[
                                    const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        const Expanded(child: Text('Número de parcelas')),
                                        IconButton.filledTonal(
                                          onPressed: _parcelas > 2
                                              ? () => setState(() => _parcelas--)
                                              : null,
                                          icon: const Icon(Icons.remove_rounded),
                                        ),
                                        SizedBox(
                                          width: 52,
                                          child: Text('$_parcelas',
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context).textTheme.titleLarge),
                                        ),
                                        IconButton.filledTonal(
                                          onPressed: _parcelas < 120
                                              ? () => setState(() => _parcelas++)
                                              : null,
                                          icon: const Icon(Icons.add_rounded),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Icon(Icons.event_rounded),
                                    title: Text(_tipo == TipoCompromisso.parcelado
                                        ? 'Data da primeira parcela'
                                        : 'Primeiro vencimento'),
                                    subtitle: Text(
                                      '${FormatoData.dia(_inicio)} · vence todo dia ${_inicio.day}',
                                    ),
                                    onTap: () async {
                                      final d = await showDatePicker(
                                        context: context,
                                        initialDate: _inicio,
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2100),
                                      );
                                      if (d != null) setState(() => _inicio = soData(d));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text('Categoria', style: Theme.of(context).textTheme.labelLarge),
                          const SizedBox(height: 8),
                          SeletorCategoria(
                            tipo: TipoCategoria.gasto,
                            selecionada: _categoriaId,
                            onSelecionar: (id) => setState(() => _categoriaId = id),
                          ),
                          const SizedBox(height: 20),
                          Text('Forma de pagamento', style: Theme.of(context).textTheme.labelLarge),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final f in FormaPagamento.values.where((f) => f != FormaPagamento.credito))
                                ChoiceChip(
                                  label: Text(f.rotulo),
                                  selected: _forma == f,
                                  showCheckmark: false,
                                  onSelected: (_) => setState(() => _forma = f),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<int>(
                            key: ValueKey('${contas.length}-$contaValida'),
                            initialValue: contaValida,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Conta que paga',
                              prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                            ),
                            items: [for (final c in contas) DropdownMenuItem(value: c.id, child: Text(c.nome))],
                            onChanged: (v) => setState(() => _contaId = v),
                          ),
                          if (_edicao)
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              value: _ativo,
                              onChanged: (v) => setState(() => _ativo = v),
                              title: const Text('Ativo'),
                              subtitle: const Text('Desligue para pausar sem apagar.'),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                      child: FilledButton(
                        onPressed: _salvar,
                        child: Text(_edicao ? 'Salvar alterações' : 'Criar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
