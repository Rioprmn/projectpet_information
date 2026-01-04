import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // REGISTER
  Future<User> register(String email, String password) async {
    try {
      UserCredential result =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user == null) {
        throw FirebaseAuthException(
          code: 'user-null',
          message: 'User tidak terbentuk',
        );
      }

      return result.user!;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // LOGIN
  Future<User> login(String email, String password) async {
    try {
      UserCredential result =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user == null) {
        throw FirebaseAuthException(
          code: 'user-null',
          message: 'User tidak ditemukan',
        );
      }

      return result.user!;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}
