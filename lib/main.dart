import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mawqif/services/cart_service.dart';
import 'package:mawqif/services/notification_service.dart';
import 'package:mawqif/routes/app_routes.dart';
import 'package:mawqif/screens/user/user_home/wishlist/wishlist_provider.dart';
import 'package:mawqif/viewmodels/auth_viewmodel.dart';
import 'constants/app_colors.dart';
import 'firebase_options.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:overlay_support/overlay_support.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Get.put(CartService());
  final notificationService = NotificationService();
  await notificationService.initFCM();

  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );
  configLoading();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],

      child: OverlaySupport.global(child: MyApp()),
    ),
  );
}

void configLoading() {
  EasyLoading.instance
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..indicatorSize = 40.0
    ..backgroundColor = const Color(0xFFF6F6F6)
    ..indicatorColor = Colors.brown.shade400
    ..textColor = Colors.brown.shade700
    ..maskColor = Colors.black.withOpacity(0.05)
    ..userInteractions = false
    ..dismissOnTap = false;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mawqif',
      builder: EasyLoading.init(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: appButtonColor),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: appButtonColor,
          selectionColor: appButtonColor.withAlpha(77),
          selectionHandleColor: appButtonColor,
        ),
      ),
      initialRoute: AppRoutes.preSplash,
      getPages: AppRoutes.routes,
    );
  }
}

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Message: ${message.notification?.title}');
}
