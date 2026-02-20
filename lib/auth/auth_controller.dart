import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AuthController {
final db = FirebaseFirestore.instance;
  Future<User?> register({required String email, required String password, required dynamic FirebaseAuth}) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    }
    catch (e) {
      print('Error: $e');
      return null;
    }
    return null;
  }

  Future<User?> login({required String email, required String password}) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      return credential.user;
    }
    catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<void> logout(dynamic FirebaseAuth) async {
    await FirebaseAuth.instance.signOut();
  }
}