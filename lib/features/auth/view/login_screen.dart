// C:\Users\sptzk\Desktop\patient_mysql\lib\features\auth\view\login_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:patient_mysql/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:patient_mysql/features/mypage/viewmodel/userinfo_viewmodel.dart'; // UserInfoViewModel 임포트

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      _showSnack('아이디와 비밀번호를 모두 입력해주세요.');
      return;
    }

    final authViewModel = context.read<AuthViewModel>();
    final userInfoViewModel = context.read<UserInfoViewModel>(); // UserInfoViewModel 인스턴스 가져오기

    try {
      final user = await authViewModel.loginUser(
        _userIdController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
        // ✅ 로그인 성공 시 UserInfoViewModel에 사용자 정보 로드
        userInfoViewModel.loadUser(user); // UserInfoViewModel의 loadUser 메서드 호출
        _showSnack('로그인 성공!');
        context.go('/home'); // 로그인 성공 시 홈 화면으로 이동
      } else {
        // 이 부분은 authViewModel.loginUser에서 이미 throw 되므로 일반적으로 여기에 도달하지 않음
        _showSnack('로그인에 실패했습니다. 아이디 또는 비밀번호를 확인해주세요.');
      }
    } catch (e) {
      _showSnack('로그인 중 네트워크 오류: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _userIdController,
                decoration: const InputDecoration(
                  labelText: '아이디',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '아이디를 입력해주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력해주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _login,
                child: const Text('로그인'),
              ),
              TextButton(
                onPressed: () {
                  context.go('/register'); // 회원가입 화면으로 이동
                },
                child: const Text('회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
