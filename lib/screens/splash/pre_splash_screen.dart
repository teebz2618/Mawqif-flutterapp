import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../constants/app_colors.dart';
import '../../routes/app_routes.dart';

class PreSplashScreen extends StatefulWidget {
  const PreSplashScreen({super.key});

  @override
  State<PreSplashScreen> createState() => _PreSplashScreenState();
}

class _PreSplashScreenState extends State<PreSplashScreen> {
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    // Animation starts after Lottie fully loads
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _isLoaded = true;
      });
      Future.delayed(const Duration(milliseconds: 2480), () {
        Get.offNamed(AppRoutes.splash);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBeige,
      body: Center(
        child:
            _isLoaded
                ? Lottie.asset(
                  'assets/images/title.json',
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                  repeat: false,
                )
                : const SizedBox(),
      ),
    );
  }
}
