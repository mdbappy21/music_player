import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/presentation/ui/screen/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _moveToNextScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 24),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 150),
              SizedBox(
                height: 220,
                child: Image.asset('assets/images/musicLogo.png'),
              ),
              const SizedBox(height: 16),
              Text('Music Player',style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18
              ),),
              Spacer(),
              const CupertinoActivityIndicator(radius: 20,color: Colors.black,),
              const SizedBox(height: 16),
              Text('Version: 1.0.0'),
            ],
          ),
        ),
      ),
    );
  }
  Future<void>_moveToNextScreen()async{
    await Future.delayed(Duration(seconds: 2));
    Get.offAll(() => HomeScreen());
  }
}
