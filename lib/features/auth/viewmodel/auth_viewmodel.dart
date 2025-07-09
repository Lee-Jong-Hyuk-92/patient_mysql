import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:patient_mysql/features/auth/model/user.dart';

class AuthViewModel with ChangeNotifier {
  final String _baseUrl;
  String? _errorMessage;
  User? _currentUser;

  AuthViewModel({required String baseUrl}) : _baseUrl = baseUrl;

  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;

  Future<bool?> checkEmailDuplicate(String email) async {
    _errorMessage = null;
    try {
      // ✅ 의사 이메일 중복 확인 경로로 변경
      final res = await http.get(Uri.parse('$_baseUrl/doctor/exists?email=$email'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['exists'] == true;
      } else {
        String message = '알 수 없는 오류 (Status: ${res.statusCode})';
        try {
          final decodedBody = json.decode(res.body);
          if (decodedBody is Map && decodedBody.containsKey('message')) {
            message = decodedBody['message'] as String;
          } else if (decodedBody is String && decodedBody.isNotEmpty) {
            message = decodedBody; // If it's a plain string error
          }
        } catch (e) {
          // Body was not valid JSON or unexpected structure, use default message
        }
        _errorMessage = '이메일 중복검사 서버 응답 오류: $message';
        if (kDebugMode) {
          print(_errorMessage);
        }
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = '이메일 중복검사 중 네트워크 오류: ${e.toString()}';
      if (kDebugMode) {
        print(_errorMessage);
      }
      notifyListeners();
      return null;
    }
  }

  Future<bool> registerUser(
    String email,
    String password, {
    required String name,
    required String phoneNumber,
    String? clinicName,
    String? clinicAddress,
    bool isDoctor = false,
  }) async {
    _errorMessage = null;
    try {
      // ✅ 의사 회원가입 경로로 변경
      final res = await http.post(
        Uri.parse('$_baseUrl/doctor/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'phoneNumber': phoneNumber,
          'clinicName': clinicName,
          'clinicAddress': clinicAddress,
          'isDoctor': isDoctor,
        }),
      );

      if (res.statusCode == 201) {
        notifyListeners();
        return true;
      } else {
        String message = '알 수 없는 오류 (Status: ${res.statusCode})';
        try {
          final decodedBody = json.decode(res.body);
          if (decodedBody is Map && decodedBody.containsKey('message')) {
            message = decodedBody['message'] as String;
          } else if (decodedBody is String && decodedBody.isNotEmpty) {
            message = decodedBody;
          }
        } catch (e) {
          // Body was not valid JSON or unexpected structure
        }
        _errorMessage = '회원가입 실패: $message';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = '네트워크 오류: ${e.toString()}';
      if (kDebugMode) {
        print('회원가입 중 네트워크 오류: $e');
      }
      notifyListeners();
      return false;
    }
  }

  Future<User?> loginUser(String email, String password) async {
    _errorMessage = null;
    try {
      // ✅ 의사 로그인 경로로 변경
      final res = await http.post(
        Uri.parse('$_baseUrl/doctor/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (res.statusCode == 200) {
        final dynamic decodedBody = jsonDecode(res.body);
        if (decodedBody is Map && decodedBody.containsKey('user') && decodedBody['user'] is Map) {
          _currentUser = User.fromJson(decodedBody['user'] as Map<String, dynamic>);
          notifyListeners();
          return _currentUser;
        } else {
          _errorMessage = '로그인 실패: 서버 응답 형식이 올바르지 않습니다.';
          notifyListeners();
          return null;
        }
      } else {
        String message = '알 수 없는 오류 (Status: ${res.statusCode})';
        try {
          final decodedBody = json.decode(res.body);
          if (decodedBody is Map && decodedBody.containsKey('message')) {
            message = decodedBody['message'] as String;
          } else if (decodedBody is String && decodedBody.isNotEmpty) {
            message = decodedBody;
          }
        } catch (e) {
          // Body was not valid JSON or unexpected structure
        }
        _errorMessage = '로그인 실패: $message';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = '네트워크 오류: ${e.toString()}';
      if (kDebugMode) {
        print('로그인 중 네트워크 오류: $e');
      }
      notifyListeners();
      return null;
    }
  }

  Future<String?> deleteUser(String email, String password) async {
    _errorMessage = null;
    try {
      // ✅ 의사 회원 탈퇴 경로로 변경
      final res = await http.delete(
        Uri.parse('$_baseUrl/doctor/delete_account'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (res.statusCode == 200) {
        notifyListeners();
        return null;
      } else {
        String message = '알 수 없는 오류 (Status: ${res.statusCode})';
        try {
          final decodedBody = json.decode(res.body);
          if (decodedBody is Map && decodedBody.containsKey('message')) {
            message = decodedBody['message'] as String;
          } else if (decodedBody is String && decodedBody.isNotEmpty) {
            message = decodedBody;
          }
        } catch (e) {
          // Body was not valid JSON or unexpected structure
        }
        _errorMessage = message;
        notifyListeners();
        return _errorMessage;
      }
    } catch (e) {
      _errorMessage = '네트워크 오류: ${e.toString()}';
      if (kDebugMode) {
        print('회원 탈퇴 중 네트워크 오류: $e');
      }
      notifyListeners();
      return _errorMessage;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
