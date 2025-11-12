
class ResetPassword {
  Future<String> resetPassword({
    required String email,
    required String password,
    required String confirmPassword,
    required String token,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    if (password != confirmPassword) {
      throw Exception('Passwords do not match');
    }

    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    return 'Password reset successful for $email';
  }
}
