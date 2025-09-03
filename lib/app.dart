import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/controller_binders.dart';
import 'package:music_player/presentation/ui/screen/splash_screen.dart';

class MusicPlayerApp extends StatelessWidget {
  const MusicPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music Player',
      theme: _lightThemeData(),
      darkTheme: _darkThemeData(),
      themeMode: ThemeMode.dark,
      home: const SplashScreen(),
      initialBinding: ControllerBinder(),
    );
  }

  ThemeData _lightThemeData() => ThemeData(

  );

  ThemeData _darkThemeData() => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.grey.shade900,
  );
}