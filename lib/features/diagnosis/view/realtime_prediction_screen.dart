import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // kIsWeb 임포트

class RealtimePredictionScreen extends StatelessWidget {
  const RealtimePredictionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('실시간 예측'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'), // 홈 화면으로 돌아가기
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (kIsWeb) // 웹 환경일 경우
              Column(
                children: [
                  const Icon(Icons.web_asset_off, size: 100, color: Colors.redAccent),
                  const SizedBox(height: 20),
                  const Text(
                    '웹에서는 실시간 예측 기능을 이용할 수 없습니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '이 기능은 Android 또는 iOS 기기에서만 지원됩니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              )
            else // Android 또는 iOS 환경일 경우
              Column(
                children: [
                  const Text(
                    '실시간 YOLOv8n-seg 모델 예측 기능이 여기에 구현됩니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  // TODO: 여기에 카메라 미리보기, 예측 결과 오버레이 등 실시간 예측 UI 및 로직 추가
                  // 예시: CameraPreview, CustomPaint 등으로 실시간 분석 결과 표시
                  Icon(Icons.camera_alt, size: 100, color: Colors.blue.shade200),
                  const SizedBox(height: 20),
                  const Text('카메라 접근 및 모델 로딩 중...', style: TextStyle(fontSize: 16)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}