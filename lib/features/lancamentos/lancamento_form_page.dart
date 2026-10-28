import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatadores/data.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/cores_lastro.dart';
import '../../core/widgets/campo_valor.dart';
import '../../data/banco.dart';
import '../../data/derivados.dart';
import '../../data/providers.dart';
import '../../data/servicos/servicos.dart';
import '../../domain/datas.dart';
import '../../domain/enums.dart';
import '../categorias/seletor_categoria.dart';

enum _Aba { gasto, ganho, movimento }

enum _SubMovimento { transferencia, aporte, resgate }

/// Lançamento rápido ("+") e edição de lançamento.
class LancamentoFormPage extends ConsumerStatefulWidget {
  const LancamentoFormPage({
    super.key,
    this.id,
    this.tipoInicial,
    this.contaInicial,
  });

  /// Edição quando não nulo.
  final int? id;

  /// `gasto`, `ganho` ou `mov` (só na criação).
  final String? tipoInicial;

  /// Conta já escolhida (ex.: "Transferir" a partir da tela de contas).
  final int? contaInicial;

  @override
  ConsumerState<LancamentoFormPage> createState() => _LancamentoFormPageState();
}

class _LancamentoFormPageState extends ConsumerState<LancamentoFormPage> {
  final _chave = GlobalKey<FormState>();
  final _valor = ControladorValor();
  final _descricao = TextEditingController();

  Lancamento? _original;
  bool _carregando = false;
  bool _salvando = false;

  _Aba _aba = _Aba.gasto;
  _SubMovimento _sub = _SubMovimento.transferencia;
  int? _categoriaId;
  FormaPagamento _forma = FormaPagamento.pix;
  int? _contaId;
  int? _contaDestinoId;
  DateTime _data = soData(DateTime.now());

  bool get _edicao => widget.id != null;

  /// Lançamentos criados pelo app (fatura, ajuste) só aceitam descrição/data.
  bool get _restrito =>
      _original != null &&
      (_original!.tipo == TipoLancamento.pagamentoFatura ||
          _original!.tipo == TipoLancamento.ajusteSaldo);

  @override
  void initState() {
    super.initState();
    _aba = switch (widget.tipoInicial) {
      'ganho' => _Aba.ganho,
      'mov' => _Aba.movimento,
      _ => _Aba.gasto,
    };
    _contaId = widget.contaInicial;
    if (_edicao) {
      _carregando = true;
      _carregar();
    }
  }

  Future<void> _carregar() async {
    final l = await ref.read(bancoProvider).lancamentosDao.obter(widget.id!);
    if (!mounted) return;
    if (l == null) {
      context.pop();
      return;
    }
    setState(() {
      _original = l;
      _carregando = false;
      _valor.centavos = l.valor.abs();
      _descricao.text = l.descricao;
      _categoriaId = l.categoriaId;
      _contaId = l.contaId;
      _contaDestinoId = l.contaDestinoId;
      _data = l.data;
      if (l.formaPagamento != null) _forma = l.formaPagamento!;
      switch (l.tipo) {
        case TipoLancamento.ganho:
          _aba = _Aba.ganho;
        case TipoLancamento.transferencia:
          _aba = _Aba.movimento;
          _sub = _SubMovimento.transferencia;
        case TipoLancamento.aporte:
          _aba = _Aba.movimento;
          _sub = _SubMovimento.aporte;
        case TipoLancamento.resgate:
          _aba = _Aba.movimento;
          _sub = _SubMovimento.resgate;
        default:
          _aba = _Aba.gasto;
      }
    });
  }

  @override
  void dispose() {
    _valor.dispose();
    _descricao.dispose();
    super.dispose();
  }

  TipoLancamento get _tipo => switch (_aba) {
        _Aba.gasto => TipoLancamento.gasto,
        _Aba.ganho => TipoLancamento.ganho,
        _Aba.movimento => switch (_sub) {
            _SubMovimento.transferencia => TipoLancamento.transferencia,
            _SubMovimento.aporte => TipoLancamento.aporte,
            _SubMovimento.resgate => TipoLancamento.resgate,
          },
      };

  Future<void> _escolherData() async {
    final nova = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (nova != null) setState(() => _data = soData(nova));
  }

  Future<void> _salvar() async {
    if (!_chave.currentState!.validate() || _salvando) return;
    final contas = ref.read(contasAtivasProvider);
    final contaId = _contaId ?? (contas.isNotEmpty ? contas.first.id : null);
    if (!_restrito && contaId == null) {
      _aviso('Cadastre uma conta antes de lançar.');
      return;
    }
    setState(() => _salvando = true);
    try {
      final servico = ref.read(servicoLancamentosProvider);
      final original = _original;
      if (original != null) {
        await servico.atualizar(_restrito
            ? original.copyWith(data: _data, descricao: _descricao.text.trim())
            : original.copyWith(
                tipo: _tipo,
                valor: _valor.centavos,
                data: _data,
                descricao: _descricao.text.trim(),
                categoriaId: Value(_aba == _Aba.movimento ? null : _categoriaId),
                formaPagamento: Value(_aba == _Aba.gasto ? _forma : null),
                contaId: Value(contaId),
                contaDestinoId: Value(
                  _tipo == TipoLancamento.transferencia ? _contaDestinoId : null,
                ),
              ));
      } else {
        await servico.registrar(
          tipo: _tipo,
          valor: _valor.centavos,
          data: _data,
          descricao: _descricao.text,
          categoriaId: _aba == _Aba.movimento ? null : _categoriaId,
          forma: _aba == _Aba.gasto ? _forma : null,
          contaId: contaId,
          contaDestinoId:
              _tipo == TipoLancamento.transferencia ? _contaDestinoId : null,
        );
      }
      if (!mounted) return;
      context.pop();
      _aviso(_edicao ? 'Lançamento atualizado' : 'Lançamento salvo');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  void _aviso(String texto) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(SnackBar(
      content: Text(texto),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = context.coresLastro;
    final contas = ref.watch(contasAtivasProvider);
    final semContas = ref.watch(contasProvider).hasValue && contas.isEmpty;
    final corValor = switch (_aba) {
      _Aba.gasto => cores.negativo,
      _Aba.ganho => cores.positivo,
      _Aba.movimento => tema.colorScheme.onSurface,
    };
    final contaId = _contaId ?? (contas.isNotEmpty ? contas.first.id : null);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Fechar',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(_edicao ? 'Editar lançamento' : 'Novo lançamento'),
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
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        children: [
                          if (!_edicao)
                            SegmentedButton<_Aba>(
                              showSelectedIcon: false,
                              segments: const [
                                ButtonSegment(
                                  value: _Aba.gasto,
                                  label: Text('Gasto'),
                                  icon: Icon(Icons.arrow_downward_rounded),
                                ),
                                ButtonSegment(
                                  value: _Aba.ganho,
                                  label: Text('Ganho'),
                                  icon: Icon(Icons.arrow_upward_rounded),
                                ),
                                ButtonSegment(
                                  value: _Aba.movimento,
                                  label: Text('Transf.'),
                                  icon: Icon(Icons.swap_horiz_rounded),
                                ),
                              ],
                              selected: {_aba},
                              onSelectionChanged: (s) =>
                                  setState(() => _aba = s.first),
                            ),
                          if (_restrito)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: _Aviso(
                                'Lançamento gerado pelo app: só a data e a '
                                'descrição podem ser alteradas.',
                              ),
                            ),
                          const SizedBox(height: 8),
                          IgnorePointer(
                            ignoring: _restrito,
                            child: Opacity(
                              opacity: _restrito ? 0.6 : 1,
                              child: CampoValor(
                                controller: _valor,
                                grande: true,
                                autofocus: !_edicao,
                                cor: corValor,
                                validator: (_) => _valor.centavos <= 0
                                    ? 'Informe um valor maior que zero'
                                    : null,
                              ),
                            ),
                          ),
                          if (semContas && !_restrito) ...[
                            const SizedBox(height: 8),
                            _Aviso(
                              'Você ainda não tem uma conta. Crie uma para '
                              'registrar lançamentos.',
                              acao: 'Criar conta',
                              onAcao: () => context.push(Rotas.novaConta),
                            ),
                          ],
                          if (!_restrito) ..._camposPrincipais(contas, contaId),
                          const SizedBox(height: 20),
                          _Secao(
                            'Data',
                            child: Row(
                              children: [
                                ActionChip(
                                  avatar: const Icon(Icons.event_rounded, size: 18),
                                  label: Text(FormatoData.dia(_data)),
                                  onPressed: _escolherData,
                                ),
                                const SizedBox(width: 8),
                                ChoiceChip(
                                  label: const Text('Hoje'),
                                  selected: mesmoDia(_data, DateTime.now()),
                                  showCheckmark: false,
                                  onSelected: (_) => setState(
                                      () => _data = soData(DateTime.now())),
                                ),
                                const SizedBox(width: 8),
                                ChoiceChip(
                                  label: const Text('Ontem'),
                                  selected: mesmoDia(
                                    _data,
                                    DateTime.now().subtract(const Duration(days: 1)),
                                  ),
                                  showCheckmark: false,
                                  onSelected: (_) => setState(() => _data = soData(
                                        DateTime.now()
                                            .subtract(const Duration(days: 1)),
                                      )),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _descricao,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              labelText: 'Descrição (opcional)',
                              prefixIcon: Icon(Icons.notes_rounded),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                      child: FilledButton(
                        onPressed: _salvando ? null : _salvar,
                        child: _salvando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.5),
                              )
                            : Text(_edicao ? 'Salvar alterações' : 'Salvar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  List<Widget> _camposPrincipais(List<Conta> contas, int? contaId) {
    return [
      if (_aba == _Aba.movimento) ...[
        const SizedBox(height: 16),
        SegmentedButton<_SubMovimento>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: _SubMovimento.transferencia, label: Text('Transferência')),
            ButtonSegment(value: _SubMovimento.aporte, label: Text('Aporte')),
            ButtonSegment(value: _SubMovimento.resgate, label: Text('Resgate')),
          ],
          selected: {_sub},
          onSelectionChanged: (s) => setState(() => _sub = s.first),
        ),
      ],
      if (_aba != _Aba.movimento) ...[
        const SizedBox(height: 20),
        _Secao(
          'Categoria',
          child: SeletorCategoria(
            tipo: _aba == _Aba.gasto ? TipoCategoria.gasto : TipoCategoria.ganho,
            selecionada: _categoriaId,
            onSelecionar: (id) => setState(() => _categoriaId = id),
          ),
        ),
      ],
      if (_aba == _Aba.gasto) ...[
        const SizedBox(height: 20),
        _Secao(
          'Forma de pagamento',
          child: Wrap(
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
        ),
      ],
      const SizedBox(height: 20),
      _Secao(
        _tipo == TipoLancamento.transferencia
            ? 'De (conta de origem)'
            : _tipo == TipoLancamento.resgate
                ? 'Para (conta que recebe)'
                : _tipo == TipoLancamento.aporte
                    ? 'Sai da conta'
                    : 'Conta',
        child: _SeletorConta(
          contas: contas,
          selecionada: contaId,
          onSelecionar: (id) => setState(() => _contaId = id),
        ),
      ),
      if (_tipo == TipoLancamento.transferencia) ...[
        const SizedBox(height: 20),
        _Secao(
          'Para (conta de destino)',
          child: _SeletorConta(
            contas: [for (final c in contas) if (c.id != contaId) c],
            selecionada: _contaDestinoId,
            onSelecionar: (id) => setState(() => _contaDestinoId = id),
            validator: (v) => v == null ? 'Escolha a conta de destino' : null,
          ),
        ),
      ],
    ];
  }
}

class _SeletorConta extends StatelessWidget {
  const _SeletorConta({
    required this.contas,
    required this.selecionada,
    required this.onSelecionar,
    this.validator,
  });
  final List<Conta> contas;
  final int? selecionada;
  final ValueChanged<int?> onSelecionar;
  final String? Function(int?)? validator;

  @override
  Widget build(BuildContext context) {
    final valida = contas.any((c) => c.id == selecionada) ? selecionada : null;
    return DropdownButtonFormField<int>(
      key: ValueKey('${contas.length}-$valida'),
      initialValue: valida,
      isExpanded: true,
      decoration: const InputDecoration(prefixIcon: Icon(Icons.account_balance_wallet_outlined)),
      hint: const Text('Escolha a conta'),
      items: [
        for (final c in contas) DropdownMenuItem(value: c.id, child: Text(c.nome)),
      ],
      onChanged: onSelecionar,
      validator: validator,
    );
  }
}

class _Secao extends StatelessWidget {
  const _Secao(this.titulo, {required this.child});
  final String titulo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso(this.texto, {this.acao, this.onAcao});
  final String texto;
  final String? acao;
  final VoidCallback? onAcao;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tema.colorScheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: tema.colorScheme.secondary),
          const SizedBox(width: 12),
          Expanded(child: Text(texto, style: tema.textTheme.bodyMedium)),
          if (acao != null) TextButton(onPressed: onAcao, child: Text(acao!)),
        ],
      ),
    );
  }
}
