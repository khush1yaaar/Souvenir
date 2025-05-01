// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:souvenir/screens/get_started_screen.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var user = Rx<User?>(null);
  var isLoading = false.obs;

  @override
  void onInit() {
    user.value = _auth.currentUser;
    _auth.authStateChanges().listen((User? newUser) {
      user.value = newUser;
    });
    super.onInit();
  }

  Future<UserCredential?> loginWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final cred = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(cred);
      await _storeUserDataIfNew(userCredential.user);
      return userCredential;
    } catch (e) {
      Get.snackbar("Login Error", e.toString());
      return null;
    }
  }

  Future<void> _storeUserDataIfNew(User? user) async {
    if (user == null) return;
    final userDoc = _firestore.collection('users').doc(user.uid);

    try {
      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        await userDoc.set({
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'journals': {},
          'createdAt': FieldValue.serverTimestamp(),
        });
        Get.snackbar("Success", "New user data stored in Firestore!");
      }
    } catch (e) {
      Get.snackbar("Firestore Error", e.toString());
    }
  }

  Future<void> logout() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
    Get.to(GetStartedScreen());
  }
}
