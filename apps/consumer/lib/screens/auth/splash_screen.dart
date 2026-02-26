import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_api/oc_api.dart';
import 'package:oc_ui/oc_ui.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scale = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    if (AuthService().isAuthenticated) {
      final authService = AuthService();
      final hasProfile = await authService.hasCompletedProfile();
      if (!mounted) return;
      if (hasProfile) {
        context.go('/home');
      } else {
        context.go('/profile-setup');
      }
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OcColors.background,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeIn.value,
              child: Transform.scale(
                scale: _scale.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Real OnlyCars logo (vertical variant)
                    const OcLogo(
                      size: 140,
                      assetPath: OcLogoAssets.vertical,
                    ),
                    const SizedBox(height: OcSpacing.lg),
                    Text(
                      'كل شي لسيارتك',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: OcColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
