import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mahee/Login_page/login_page.dart';
import 'package:mahee/app.dart';
import 'package:mahee/firebase_options.dart';
import 'package:mahee/exercise_tracher_app.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

