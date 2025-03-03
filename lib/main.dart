import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mawqif/routes/app_routes.dart';
import 'package:mawqif/viewmodels/auth_viewmodel.dart';
import 'constants/app_colors.dart';
import 'firebase_options.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );
  configLoading();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthViewModel())],
      child: MyApp(),
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
