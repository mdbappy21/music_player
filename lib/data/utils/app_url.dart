import 'package:cloud_firestore/cloud_firestore.dart';

class AppUrl{
  static FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  static String id='';
  static Future<void> getUpdateId() async {
    try {
      final DocumentSnapshot result = await firebaseFirestore.collection('url').doc('update').get();
      if (result.exists) {
        id = result.get('id');
      } else {
        id = '1r6_GsKjxqJF4B6lEofAiX-U4VTKyes8V';
      }
    } catch (e) {
      id = '1r6_GsKjxqJF4B6lEofAiX-U4VTKyes8V';
    }
  }
  static String updateVersionUrl = 'https://drive.google.com/uc?export=download&id=$id';
}