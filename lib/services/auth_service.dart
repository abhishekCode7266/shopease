import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // Stream of Auth changes
  Stream<User?> get authStateChanges {
    try {
      return _auth.authStateChanges();
    } catch (_) {
      return const Stream<User?>.empty();
    }
  }

  // Current Firebase User
  User? get currentUser {
    try {
      return _auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  // Sign Up with Email and Password
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('User creation failed.');
      }

      await user.updateDisplayName(name.trim());

      final userModel = UserModel(
        uid: user.uid,
        name: name.trim(),
        email: email.trim(),
        createdAt: DateTime.now(),
      );

      // Save user profile to Firestore
      await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(user.uid)
          .set(userModel.toMap());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw getFriendlyErrorMessage(e);
    } catch (e) {
      throw 'An error occurred during registration. Please try again.';
    }
  }

  // Sign In with Email and Password
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Sign in failed.');
      }

      final doc = await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      } else {
        // Create fallback profile if missing
        final fallback = UserModel(
          uid: user.uid,
          name: user.displayName ?? 'User',
          email: user.email ?? email,
          createdAt: DateTime.now(),
        );
        await _firestore
            .collection(AppConstants.collectionUsers)
            .doc(user.uid)
            .set(fallback.toMap());
        return fallback;
      }
    } on FirebaseAuthException catch (e) {
      throw getFriendlyErrorMessage(e);
    } catch (e) {
      throw 'Sign in failed. Please check your credentials.';
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Failed to sign out. Please try again.';
    }
  }

  // Send Password Reset Email
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw getFriendlyErrorMessage(e);
    } catch (e) {
      throw 'Failed to send password reset email. Please try again.';
    }
  }

  // Update Profile Name
  Future<void> updateProfileName(String newName) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await user.updateDisplayName(newName.trim());
      await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(user.uid)
          .update({'name': newName.trim()});
    } catch (e) {
      throw 'Failed to update profile name.';
    }
  }

  // Delete Account
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(user.uid)
          .delete();
      await user.delete();
    } catch (e) {
      throw 'Failed to delete account. You may need to sign in again first.';
    }
  }

  // Get User Profile from Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(uid)
          .get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Friendly error message converter
  static String getFriendlyErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email. Please sign up.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists. Try logging in.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed login attempts. Please wait a few minutes and try again.';
      case 'invalid-credential':
        return 'Invalid email or password. Please verify and try again.';
      case 'network-request-failed':
        return 'Network connection error. Please check your internet connection.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}
