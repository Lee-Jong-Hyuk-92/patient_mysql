import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:provider/provider.dart';

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
      final baseUrl = authViewModel.baseUrl;
      final userId = authViewModel.loggedInUser?.username ?? 'anonymous';
      final uri = Uri.parse('$baseUrl/upload_masked_image');

      http.MultipartRequest request = http.MultipartRequest('POST', uri)
        ..fields['user_id'] = userId;

      if (kIsWeb) {
        // 웹용 MultipartFile 생성
        final bytes = await _selectedImage!.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: _selectedImage!.name,
          contentType: MediaType('image', 'jpeg'),
        ));
      } else {
        // 모바일용 MultipartFile 생성
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          _selectedImage!.path,
          contentType: MediaType('image', 'jpeg'),
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
