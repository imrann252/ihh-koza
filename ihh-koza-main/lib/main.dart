import 'package:flutter/material.dart';
import 'services/hive_service.dart';
import 'views/login_view.dart';
import 'state/app_state.dart';
import 'constants/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🚀 Yerel disk veri kuryesi motorunu (Hive) burada ayağa kaldırıyoruz
  await HiveService.init();

  runApp(
    AppStateProvider(
      state: AppState(),
      child: const KozaApp(),
    ),
  );
}

class KozaApp extends StatelessWidget {
  const KozaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'İHH KOZA - Operasyon Yönetim Sistemi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.backgroundWhite,
        primaryColor: AppColors.kozaGreen,
        fontFamily: 'Inter', // Eğer varsa
      ),
      home: const LoginView(),
    );
  }
}