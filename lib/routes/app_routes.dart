import 'package:get/get.dart';
import 'package:mawqif/screens/brand/brand_dashboard.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/auth/login/login.dart';
import '../screens/auth/register/brand_register.dart';
import '../screens/auth/register/user_register.dart';
import '../screens/auth/forgot/forgot_password_screen.dart';
import '../screens/splash/pre_splash_screen.dart';
import '../screens/splash/splash_screen.dart';
import 'package:mawqif/screens/user/user_dashboard.dart';
import '../screens/welcome/welcome_screen.dart';

class AppRoutes {
  static const preSplash = '/';
  static const splash = '/splash';
  static const welcome = '/welcome';
  static const login = '/login';
  static const forgot = '/forgot';
  static const userRegister = '/userRegister';
  static const brandRegister = '/brandRegister';
  static const userDashboard = '/userDashboard';
  static const adminDashboard = '/adminDashboard';
  static const brandDashboard = '/brandDashboard';

  static final routes = [
    GetPage(name: preSplash, page: () => const PreSplashScreen()),
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: welcome, page: () => const WelcomeScreen()),
    GetPage(name: login, page: () => SignInScreen()),
    GetPage(name: forgot, page: () => const ForgotPasswordScreen()),
    GetPage(name: userRegister, page: () => UserSignUpScreen()),
    GetPage(name: brandRegister, page: () => BrandSignUpScreen()),
    GetPage(name: userDashboard, page: () => UserDashboard()),
    GetPage(name: adminDashboard, page: () => AdminDashboard()),
    GetPage(name: brandDashboard, page: () => BrandDashboard()),
  ];
}
