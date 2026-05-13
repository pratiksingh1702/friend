import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router.dart';
import 'core/services/local_store.dart';
import 'core/theme.dart';
import 'core/widgets/services_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStore.instance.init();
  runApp(
    const ProviderScope(
      child: ServicesInitializer(
        child: HumanTypeApp(),
      ),
    ),
  );
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
