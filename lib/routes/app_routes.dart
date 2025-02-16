import 'package:get/get.dart';
import 'package:mawqif/screens/brand/brand_dashboard.dart';
import 'package:mawqif/screens/brand/brand_pending_screen.dart';
import 'package:mawqif/screens/brand/brand_rejected.dart';
import '../screens/admin/views/admin_dashboard.dart';
import '../screens/admin/views/brand_detail.dart';
import '../screens/auth/login/login.dart';
import '../screens/auth/register/brand_logo.dart';
import '../screens/auth/register/brand_register.dart';
import '../screens/auth/register/user_register.dart';
import '../screens/auth/forgot/forgot_password_screen.dart';
import '../screens/splash/pre_splash_screen.dart';
import '../screens/splash/splash_screen.dart';
import 'package:mawqif/screens/user/user_dashboard.dart';
import '../screens/welcome/welcome_screen.dart';
import '../screens/auth/register/password_prompt.dart';

class AppRoutes {
  static const preSplash = '/';
  static const splash = '/splash';
  static const welcome = '/welcome';
  static const login = '/login';
  static const forgot = '/forgot';
  static const userRegister = '/userRegister';
  static const passwordPrompt = '/passwordPrompt';
  static const brandRegister = '/brandRegister';
  static const userDashboard = '/userDashboard';
  static const adminDashboard = '/adminDashboard';
  static const brandDashboard = '/brandDashboard';
  static const brandPending = '/brandPending';
  static const brandDetail = '/brandDetail';
  static const logoUpload = '/logoUpload';
  static const brandReject = '/brandRejected';

  static final routes = [
    GetPage(name: preSplash, page: () => const PreSplashScreen()),
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: welcome, page: () => const WelcomeScreen()),
    GetPage(name: login, page: () => SignInScreen()),
    GetPage(name: forgot, page: () => const ForgotPasswordScreen()),
    GetPage(name: userRegister, page: () => UserSignUpScreen()),
    GetPage(name: passwordPrompt, page: () => PasswordPromptScreen()),
    GetPage(name: brandRegister, page: () => BrandSignUpScreen()),
    GetPage(name: logoUpload, page: () => UploadLogoScreen()),
    GetPage(name: userDashboard, page: () => UserDashboard()),
    GetPage(name: adminDashboard, page: () => AdminDashboard()),
    GetPage(name: brandDetail, page: () => BrandDetailScreen()),
    GetPage(name: brandDashboard, page: () => BrandDashboard()),
    GetPage(name: brandPending, page: () => BrandPendingScreen()),
    GetPage(name: brandReject, page: () => BrandRejectionReasonScreen()),
  ];
}
