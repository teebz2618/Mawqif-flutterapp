import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mawqif/routes/app_routes.dart';
import 'constants/app_colors.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mawqif',
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
