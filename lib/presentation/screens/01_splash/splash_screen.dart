import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void _handleTap(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.languageSelection,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _handleTap(context),
        child: SizedBox.expand(
          child: Image.asset(
            'assets/images/splash_screen.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}