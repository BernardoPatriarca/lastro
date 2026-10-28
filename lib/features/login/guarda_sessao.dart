import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_controller.dart';

/// Observa o ciclo de vida: ao voltar do segundo plano depois do tempo
/// configurado (padrão 2 min), bloqueia o app.
class GuardaSessao extends ConsumerStatefulWidget {
  const GuardaSessao({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<GuardaSessao> createState() => _GuardaSessaoState();
}

class _GuardaSessaoState extends ConsumerState<GuardaSessao>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    final auth = ref.read(authProvider.notifier);
    switch (estado) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        auth.foiParaSegundoPlano();
      case AppLifecycleState.resumed:
        auth.voltouDoSegundoPlano();
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
