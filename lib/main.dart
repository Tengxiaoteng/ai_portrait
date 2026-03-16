import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'config/theme.dart';
import 'config/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force landscape orientation for tablet optimisation.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Hide status bar and navigation bar for immersive experience.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const AiPortraitApp());
}

class AiPortraitApp extends StatelessWidget {
  const AiPortraitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Portrait',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
