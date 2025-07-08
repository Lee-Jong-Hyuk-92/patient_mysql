//C:\Users\user\Desktop\0703flutter_v2\lib\core\strategy\auth_strategy.dart
abstract class AuthStrategy {
  Future<bool> login(String userId, String password);
  Future<bool> register(String userId, String password, String name);
  Future<void> logout();
}