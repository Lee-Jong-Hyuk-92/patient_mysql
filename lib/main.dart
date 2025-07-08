// C:\Users\sptzk\Desktop\patient_mysql\lib\main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform; // defaultTargetPlatform 임포트 유지

import 'app/router.dart';
import 'app/theme.dart';
import 'features/auth/viewmodel/auth_viewmodel.dart';
import 'features/mypage/viewmodel/userinfo_viewmodel.dart';
import 'features/chatbot/viewmodel/chatbot_viewmodel.dart';
import 'features/diagnosis/viewmodel/diagnosis_viewmodel.dart';

// ✅ 새로운 기능 ViewModel 임포트 추가 (경로 확인)
import 'features/history/viewmodel/history_viewmodel.dart';
import 'features/non_face_to_face/viewmodel/consultation_viewmodel.dart';
import 'features/nearby_clinics/viewmodel/clinic_viewmodel.dart';


void main() {
  // ✅ 중요: 아래 globalBaseUrl을 현재 Flutter 앱이 실행되는 환경에 맞게 정확히 설정해주세요.
  // 백엔드 서버(Node.js Express)는 'http://localhost:3000'에서 실행 중입니다.
  // Flutter 앱이 백엔드에 접근하려면, 앱이 실행되는 환경에서 'localhost:3000'에 어떻게 접근해야 하는지 알아야 합니다.

  const String globalBaseUrl = "https://fe21876d118d.ngrok-free.app/api";

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthViewModel(baseUrl: globalBaseUrl)),
        ChangeNotifierProvider(create: (context) => UserInfoViewModel(baseUrl: globalBaseUrl)), // UserInfoViewModel에 baseUrl이 필요하다면 추가
        ChangeNotifierProvider(create: (context) => ChatbotViewModel(baseUrl: globalBaseUrl)),
        ChangeNotifierProvider(create: (context) => DiagnosisViewModel(baseUrl: globalBaseUrl)),
        // ✅ 새로운 기능 ViewModel 추가
        ChangeNotifierProvider(create: (context) => HistoryViewModel(baseUrl: globalBaseUrl)),
        ChangeNotifierProvider(create: (context) => ConsultationViewModel(baseUrl: globalBaseUrl)),
        ChangeNotifierProvider(create: (context) => ClinicViewModel(baseUrl: globalBaseUrl)),
      ],
      child: const MediToothApp(),
    ),
  );
}

class MediToothApp extends StatelessWidget {
  const MediToothApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MediTooth',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
