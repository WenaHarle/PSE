import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get user => _auth.currentUser;

  Stream<User?> get authState => _auth.authStateChanges();

  Future<Map<String, dynamic>?> signInWithusername(String username, String password) async {
    try {
      // Query Firestore to find a user with the given full name
      QuerySnapshot result = await _firestore.collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        var userData = result.docs.first.data() as Map<String, dynamic>;

        // Check if the password matches
        if (userData['password'] == password) {
          return userData;
        } else {
          throw FirebaseAuthException(code: 'wrong-password', message: 'Password is incorrect');
        }
      } else {
        throw FirebaseAuthException(code: 'user-not-found', message: 'User not found');
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return result.user;
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
