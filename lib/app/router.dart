// C:\Users\user\Desktop\0703flutter_v2\lib\app\router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/view/login_screen.dart';
import '../features/auth/view/register_screen.dart';
import '../features/home/view/main_scaffold.dart'; // MainScaffold 임포트
import '../features/home/view/home_screen.dart'; // HomeScreen 임포트 (MainScaffold의 자식으로 사용)
import '../features/chatbot/view/chatbot_screen.dart';
import '../features/mypage/view/mypage_screen.dart';
import '../features/diagnosis/view/upload_screen.dart';
import '../features/diagnosis/view/result_screen.dart';
import '../features/history/view/history_screen.dart'; // 기존 HistoryScreen 임포트
import '../features/diagnosis/view/realtime_prediction_screen.dart';
import '../features/mypage/view/edit_profile_screen.dart';
import '../features/auth/view/find-Account_screen.dart';

// ✅ 새로운 기능 화면 임포트 추가
import '../features/history/view/history_detail_screen.dart'; // 진단 내역 상세 화면
import '../features/non_face_to_face/view/consultation_list_screen.dart'; // 비대면 진단 결과 목록
import '../features/non_face_to_face/view/consultation_detail_screen.dart'; // 비대면 진단 결과 상세
import '../features/nearby_clinics/view/clinic_list_screen.dart'; // 주변 치과 목록
import '../features/nearby_clinics/view/clinic_detail_screen.dart'; // 치과 상세 정보
import '../features/nearby_clinics/view/clinic_booking_screen.dart'; // 치과 예약 화면


class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>(); // ShellRoute를 위한 별도의 NavigatorKey

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey, // 최상위 NavigatorKey
    initialLocation: '/login', // 앱 시작 시 초기 경로
    routes: [
      // 로그인 및 회원가입 화면 (하단 탭 바 없음)
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/find-account', // 이 경로로 FindAccountScreen에 접근할 수 있습니다.
        builder: (context, state) => const FindAccountScreen(),
      ),

      // ShellRoute: 하단 탭 바가 있는 화면들을 감싸는 역할
      ShellRoute(
        navigatorKey: _shellNavigatorKey, // ShellRoute는 자체 NavigatorKey를 가집니다.
        builder: (context, state, child) {
          // MainScaffold가 하단 탭 바를 제공하고, child는 현재 선택된 탭의 화면입니다.
          return MainScaffold(child: child, currentLocation: state.uri.toString());
        },
        routes: [
          // MainScaffold 내부에 표시될 탭 화면들
          GoRoute(
            path: '/home', // 홈 탭
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/chatbot', // 챗봇 탭
            builder: (context, state) => const ChatbotScreen(),
          ),
          GoRoute(
            path: '/mypage', // 마이페이지 탭
            builder: (context, state) => const MyPageScreen(),
            routes: [
              // 개인정보 수정 화면은 마이페이지 탭의 하위 라우트로 중첩
              GoRoute(
                path: 'edit', // '/mypage/edit' 경로가 됨
                builder: (context, state) => const EditProfileScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/history', // 진단 기록 화면 (탭에서 접근 가능)
            builder: (context, state) => const HistoryScreen(),
            routes: [
              // ✅ 진단 내역 상세 화면 라우트 추가
              GoRoute(
                path: 'detail/:id', // 예: /history/detail/123
                builder: (context, state) {
                  final String historyId = state.pathParameters['id']!;
                  return HistoryDetailScreen(historyId: historyId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/upload', // 사진 진단 업로드 화면 (탭에서 접근 가능)
            builder: (context, state) => const UploadScreen(),
          ),
          GoRoute(
            path: '/result', // 진단 결과 화면 (탭에서 접근 가능)
            builder: (context, state) => const ResultScreen(),
          ),
          // ✅ 비대면 진단 결과 화면 라우트 추가
          GoRoute(
            path: '/consultations',
            builder: (context, state) => const ConsultationListScreen(),
            routes: [
              GoRoute(
                path: 'detail/:id', // 예: /consultations/detail/456
                builder: (context, state) {
                  final String consultationId = state.pathParameters['id']!;
                  return ConsultationDetailScreen(consultationId: consultationId);
                },
              ),
            ],
          ),
          // ✅ 주변 치과 화면 라우트 추가
          GoRoute(
            path: '/clinics',
            builder: (context, state) => const ClinicListScreen(),
            routes: [
              GoRoute(
                path: 'detail/:id', // 예: /clinics/detail/789
                builder: (context, state) {
                  final String clinicId = state.pathParameters['id']!;
                  return ClinicDetailScreen(clinicId: clinicId);
                },
              ),
              GoRoute(
                path: 'book/:id', // 예: /clinics/book/789
                builder: (context, state) {
                  final String clinicId = state.pathParameters['id']!;
                  return ClinicBookingScreen(clinicId: clinicId);
                },
              ),
            ],
          ),
        ],
      ),

      // ShellRoute 외부에 있는 화면 (하단 탭 바 없음)
      GoRoute(
        path: '/diagnosis/realtime',
        builder: (context, state) => const RealtimePredictionScreen(),
      ),
    ],
  );
}
