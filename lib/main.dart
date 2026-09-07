import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/theme_constants.dart';
import 'providers/inspector_provider.dart';
import 'views/main_navigation_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MultiPerspectiveInspectorApp());
}

class MultiPerspectiveInspectorApp extends StatelessWidget {
  const MultiPerspectiveInspectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InspectorProvider()),
      ],
      child: MaterialApp(
        title: '多职业视角图像解读器',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainNavigationShell(),
      ),
    );
  }
}
