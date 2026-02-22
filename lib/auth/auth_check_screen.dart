import 'package:flutter/material.dart';
import '../features/auth/domain/entities/user.dart';
import '../features/admin/presentation/pages/auth_check_screen.dart' as legacy;

class AuthCheckScreen extends StatelessWidget {
  final User user;

  const AuthCheckScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return legacy.AuthCheckScreen(user: user);
  }
}
