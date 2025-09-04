import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/presentation/ui/screen/home_screen.dart';
import 'package:music_player/presentation/ui/screen/update_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String appVersion='';
  bool _needUpdate = false;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    getAppVersion();
    _checkUpdate();
    _moveToNextScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade400,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 150),
              SizedBox(
                height: 220,
                child: Image.asset('assets/images/musicLogo.png'),
              ),
              const SizedBox(height: 48),
              Text(
                'Music Player',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              Spacer(),
              const CupertinoActivityIndicator(radius: 20, color: Colors.black),
              const SizedBox(height: 24),
              Text('Version $appVersion',style: const TextStyle(color: Colors.black),),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    appVersion=info.version;
    setState(() {});
  }

  Future<void> _checkUpdate() async {
    try {
      final DocumentSnapshot updateStatus = await firebaseFirestore.collection('update_status').doc('isAvailable').get().timeout(const Duration(seconds: 2));
      if (updateStatus.exists) {
        String updateVersion = updateStatus.get('version');
        if (appVersion != updateVersion) {
          setState(() {
            _needUpdate = true;
          });
        }
      }
    } catch (e) {
      setState(() {
        _needUpdate = false;
      });
    }
    setState(() {});
  }
  Future<void> _moveToNextScreen() async {
    await Future.delayed(Duration(seconds: 3));
    Get.offAll(()=>_needUpdate?UpdateScreen(appVersion: appVersion) : HomeScreen(),);
  }
}
