import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/data/utils/app_url.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateScreen extends StatelessWidget {
  const UpdateScreen({super.key, required this.appVersion});
  final String appVersion;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDialog();
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (value, _) {
          _showDialog();
        },
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 48),
              Image.asset('assets/images/musicLogo.png'),
              // SvgPicture.asset(AssetsPath.appLogo, width: 220),
              const Spacer(),
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

  void _showDialog() {
    Get.defaultDialog(
      title: "Update Required",
      middleText: "A new version of the app is available. Please update to continue.",
      textConfirm: "Update",
      textCancel: "Later",
      barrierDismissible: false,
      onConfirm: () {
        _onTapUpdate();
      },
      onCancel: () {
        Get.back();
      },
    );
  }

  Future<void> _onTapUpdate() async {
    await AppUrl.getUpdateId();

    final String url = AppUrl.updateVersionUrl;
    final Uri uri = Uri.parse(url);

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      Get.snackbar("Error", "Failed to open update link: $e");
    }
  }
}
