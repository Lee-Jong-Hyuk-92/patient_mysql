import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  bool _imageSelected = false;

  void _selectImage() async {
    // TODO: 갤러리 또는 카메라에서 이미지 선택 구현
    setState(() {
      _imageSelected = true;
    });
  }

  void _submitDiagnosis() {
    if (_imageSelected) {
      // TODO: 진단 요청 API 호출
      context.go('/result'); // 결과 화면으로 이동
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사진 진단'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // ✅ 이전 화면 (홈 화면)으로 직접 이동
            // context.pop()이 예상대로 작동하지 않거나 항상 홈으로 가야 할 경우 사용
            context.go('/home'); 
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('진단할 사진을 업로드하세요'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectImage,
              child: const Text('+ 사진 선택'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _imageSelected ? _submitDiagnosis : null,
              child: const Text('제출'),
            ),
          ],
        ),
      ),
    );
  }
}