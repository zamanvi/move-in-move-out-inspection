import 'package:flutter/material.dart';
import 'services/storage_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const InspectionApp());
}

class InspectionApp extends StatelessWidget {
  const InspectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF2E5266);
    return MaterialApp(
      title: 'Inspection Report Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: false),
      ),
      home: const HomeScreen(),
    );
  }
}
