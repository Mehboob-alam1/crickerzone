import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/constants/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      context.go('/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeInDown(
              duration: const Duration(milliseconds: 800),
              child: ZoomIn(
                duration: const Duration(milliseconds: 1000),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.sports_cricket,
                    size: 80,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              duration: const Duration(milliseconds: 800),
              delay: const Duration(milliseconds: 500),
              child: Text(
                'SCORE ZONE',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      letterSpacing: 4,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
            const SizedBox(height: 48),
            FadeIn(
              delay: const Duration(milliseconds: 1200),
              child: const SpinKitThreeBounce(
                color: AppColors.primary,
                size: 25.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
