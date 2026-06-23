import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  // Stream status login
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current Firebase User
  User? get currentUser => _auth.currentUser;

  // Fetch complete User Profile from Firestore
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
    return null;
  }

  // Login — auto-creates Firestore profile on first login if missing
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = credential.user!.uid;
      UserModel? userProfile = await getUserProfile(uid);

      // --- Auto-create profile if it doesn't exist yet ---
      // This handles the case where the account was created in Firebase Console
      // but the Firestore document was not manually created.
      if (userProfile == null) {
        final firebaseUser = credential.user!;
        final newProfile = UserModel(
          id: uid,
          name: firebaseUser.displayName ?? email.split('@').first,
          email: firebaseUser.email ?? email.trim(),
          role: 'owner', // First-time auto-created user gets owner role
          createdAt: DateTime.now(),
        );
        await _db.collection('users').doc(uid).set(newProfile.toMap());
        userProfile = newProfile;
        print('Auto-created user profile for $uid with role: owner');
      }

      return {'success': true, 'role': userProfile.role, 'user': userProfile};
    } on FirebaseAuthException catch (e) {
      String message = 'Terjadi kesalahan login.';
      if (e.code == 'user-not-found') {
        message = 'Email tidak terdaftar.';
      } else if (e.code == 'wrong-password') {
        message = 'Password salah.';
      } else if (e.code == 'invalid-email') {
        message = 'Format email tidak valid.';
      } else if (e.code == 'invalid-credential') {
        message = 'Email atau password salah.';
      } else if (e.message != null) {
        message = e.message!;
      }
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
