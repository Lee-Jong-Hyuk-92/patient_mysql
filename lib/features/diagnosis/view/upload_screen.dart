import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/foundation.dart'; // kIsWeb 임포트
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:provider/provider';

// Web 전용
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import '../../auth/viewmodel/auth_viewmodel.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _selectImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('갤러리에서 선택'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() => _selectedImage = pickedFile);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('카메라로 촬영'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await _picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() => _selectedImage = pickedFile);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitDiagnosis() async {
    if (_selectedImage == null) return;
    setState(() => _isUploading = true);

    try {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      // AuthViewModel에 baseUrl이 없으므로, main.dart에서 직접 가져오거나 AuthViewModel에 추가해야 합니다.
      // 현재 AuthViewModel에는 baseUrl이 있지만, 접근 방식이 loggedInUser?.username과 같이 직접적이지 않습니다.
      // 여기서는 baseUrl을 AuthViewModel의 속성으로 가정합니다.
      final baseUrl = authViewModel.baseUrl; // AuthViewModel에 baseUrl getter가 필요합니다.
      
      // 사용자 ID는 로그인한 사용자의 username을 사용합니다.
      // 환자 앱이므로 User 모델의 username을 사용합니다.
      final userId = authViewModel.currentUser?.username ?? 'anonymous'; 
      final uri = Uri.parse('$baseUrl/upload_masked_image');

      http.MultipartRequest request = http.MultipartRequest('POST', uri)
        ..fields['user_id'] = userId;

      // ✅ 웹과 모바일 환경에 따라 이미지 파일 처리 방식 분기
      if (kIsWeb) {
        // 웹용 MultipartFile 생성: 이미지 바이트를 직접 읽어 전송
        final bytes = await _selectedImage!.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: _selectedImage!.name,
          contentType: MediaType('image', 'jpeg'), // 적절한 MIME 타입 설정
        ));
      } else {
        // 모바일용 MultipartFile 생성: 이미지 파일 경로를 사용하여 전송
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          _selectedImage!.path,
          contentType: MediaType('image', 'jpeg'), // 적절한 MIME 타입 설정
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (mounted) context.go('/result', extra: result);
      } else {
        final error = jsonDecode(response.body);
        _showError(error['error'] ?? '진단 실패: 서버 오류');
      }
    } catch (e) {
      _showError('네트워크 오류: $e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildPreview() {
    if (_selectedImage == null) {
      return const Text('진단할 사진을 업로드하세요');
    }

    // ✅ 웹과 모바일 환경에 따라 이미지 미리보기 방식 분기
    return kIsWeb
        ? Image.network(_selectedImage!.path, width: 200, height: 200, fit: BoxFit.cover)
        : Image.file(io.File(_selectedImage!.path), width: 200, height: 200, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사진 진단'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPreview(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUploading ? null : _selectImage,
              child: const Text('+ 사진 선택'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: (_selectedImage != null && !_isUploading) ? _submitDiagnosis : null,
              child: _isUploading
                  ? const CircularProgressIndicator()
                  : const Text('제출'),
            ),
          ],
        ),
      ),
    );
  }
}
