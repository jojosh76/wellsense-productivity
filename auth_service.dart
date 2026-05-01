import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // ✅ AJOUT
import '../services/user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  /// 🔐 LOGIN EMAIL / PASSWORD
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential res =
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (res.user != null) {
        await _userService.saveUser(res.user!);
      }

      return res.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Erreur de connexion";
    }
  }

  /// 📝 REGISTER EMAIL / PASSWORD
  Future<User?> registerWithEmail(
    String email,
    String password,
    String name,
  ) async {
    try {
      final UserCredential res =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (res.user != null) {
        await _userService.saveUser(
          res.user!,
          additionalData: {
            'name': name,
            'provider': 'email',
          },
        );
      }

      return res.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Erreur d'inscription";
    }
  }

  /// 🔐 GOOGLE SIGN-IN (ANDROID FIX)
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
        ],
      );

      final GoogleSignInAccount? googleUser =
          await googleSignIn.signIn();

      if (googleUser == null) return null; // utilisateur annule

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential res =
          await _auth.signInWithCredential(credential);

      if (res.user != null) {
        await _userService.saveUser(
          res.user!,
          additionalData: {
            'name':
                res.user!.displayName ?? 'Utilisateur Google',
            'provider': 'google',
          },
        );
      }

      return res.user;
    } on FirebaseAuthException catch (e) {
      throw "Erreur Firebase : ${e.message}";
    } catch (e) {
      throw "Erreur Google Sign-In : $e";
    }
  }

  /// 🚪 LOGOUT
  Future<void> signOut() async {
    await GoogleSignIn().signOut(); // ✅ important
    await _auth.signOut();
  }

  /// 👤 CURRENT USER
  User? get currentUser => _auth.currentUser;
}