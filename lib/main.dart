import 'package:flutter/material.dart';
import 'theme.dart';
import 'state/app_state.dart';
import 'screens/onboarding_screen.dart';

/// main() — точка входа. runApp() монтирует корневой виджет.
void main() => runApp(const MiniRoot());

/// MiniRoot — корень. Stateful, потому что владеет объектом AppState (создаёт его
/// один раз и освобождает при завершении). AppScope раздаёт состояние вниз.
class MiniRoot extends StatefulWidget {
  const MiniRoot({super.key});
  @override
  State<MiniRoot> createState() => _MiniRootState();
}

class _MiniRootState extends State<MiniRoot> {
  final AppState _state = AppState();

  @override
  void dispose() {
    _state.dispose(); // ChangeNotifier нужно освобождать
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // AppScope стоит ВЫШЕ MaterialApp — значит любой экран, открытый через
    // Navigator, тоже видит состояние (он строится под этим AppScope).
    return AppScope(
      notifier: _state,
      child: MaterialApp(
        title: 'MINI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.paper,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.ink, primary: AppColors.ink),
          useMaterial3: true,
        ),
        home: const OnboardingScreen(),
      ),
    );
  }
}
