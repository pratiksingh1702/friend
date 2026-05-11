import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router.dart';
import 'core/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: HumanTypeApp()));
}

class HumanTypeApp extends StatelessWidget {
  const HumanTypeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HumanType',
      debugShowCheckedModeBanner: false,
      theme: buildHumanTypeTheme(),
      routerConfig: appRouter,
    );
  }
}
