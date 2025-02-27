import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tapon_vending/profile/profile_model.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Sign Up
  Future<UserCredential?> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Sign In
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Forgot Password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get Current User
  User? getCurrentUser() {
    return _auth.currentUser;
  }
 
  // Fetch User Profile Data
  Future<UserProfileModel?> getUserProfile() async {
    User? user = _auth.currentUser;
    if (user == null) return null;

    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        return UserProfileModel(
          name: userDoc['name'] ?? '',
          email: userDoc['email'] ?? '',
          mobile: userDoc['mobile'] ?? '',
          password: '', // Don't retrieve the password for security reasons
        );
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
    return null;
  }

  // Update User Profile Data
  Future<void> updateUserProfile(UserProfileModel profile) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'name': profile.name,
        'email': profile.email,
        'mobile': profile.mobile,
      });
    } catch (e) {
      print("Error updating user data: $e");
    }
  } 
}
