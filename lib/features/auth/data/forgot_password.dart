class ForgotPassword {
  Future<String> sendResetLink(String email) async {
    await Future.delayed(const Duration(seconds: 2));

    if (email.contains('@')) {
      return 'Reset link sent successfully to $email';
    } else {
      throw Exception('Invalid email address');
    }
  }
}
