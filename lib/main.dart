import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wakelock/wakelock.dart';
import 'package:walton_video_conference/register.dart';
import 'package:walton_video_conference/user_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:walton_video_conference/video_conference_interface.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
  Wakelock.enable();
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UserRegister(),
    );
  }
}
