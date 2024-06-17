import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<User?> createUserWithEmailAndPassword(
      String email, String password, String name) async {
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      throw Exception('Email, password, and name cannot be empty');
    }
    try {
      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _fireStore.collection('users').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'email': email,
        'name': name,
      });
      return cred.user;
    } on FirebaseAuthException catch (e) {
      log('Error during user creation: ${e.message}', error: e);
      rethrow;
    } catch (e) {
      log('Unexpected error during user creation: $e');
      rethrow;
    }
  }

  Future<User?> loginUserWithEmailAndPassword(
      String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password cannot be empty');
    }
    try {
      final UserCredential cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      await _fireStore.collection('users').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'email': email,
      }, SetOptions(merge: true));

      return cred.user;
    } on FirebaseAuthException catch (e) {
      log('Error during login: ${e.message}', error: e);
      rethrow;
    } catch (e) {
      log('Unexpected error during login: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      log('Error during sign out: ${e.message}', error: e);
      rethrow;
    } catch (e) {
      log('Unexpected error during sign out: $e');
      rethrow;
    }
  }
}
