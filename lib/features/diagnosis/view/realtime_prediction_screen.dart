import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // go() 사용을 위한 import

class RealtimePredictionScreen extends StatefulWidget {
  const RealtimePredictionScreen({super.key});

  @override
  State<RealtimePredictionScreen> createState() => _RealtimePredictionScreenState();
}

class _RealtimePredictionScreenState extends State<RealtimePredictionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('실시간 예측'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // ✅ 홈 화면으로 안전하게 이동
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context.go('/home'); // 홈 경로로 이동
              }
            });
          },
        ),
      ),
      body: const Center(
        child: Text(
          '구현 예정',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
