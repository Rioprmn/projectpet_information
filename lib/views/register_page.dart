import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controller untuk mengambil teks dari inputan user
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  // Fungsi untuk mendaftarkan user baru ke Firebase
  Future<void> _signUp() async {
    // 1. Validasi jika ada field yang kosong
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty) {
      _showError("Semua data harus diisi! ⚠️");
      return;
    }

    // 2. Validasi apakah password dan konfirmasi password sama
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError("Password tidak cocok! ❌");
      return;
    }

    // 3. Tampilkan loading
    setState(() => _isLoading = true);

    try {
      // 4. Proses kirim data ke Firebase Auth
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 5. Jika sukses
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pendaftaran Berhasil! 🎉 Silakan Login."),
          ),
        );
        Navigator.pop(context); // Kembali ke halaman Login
      }
    } on FirebaseAuthException catch (e) {
      // 6. Tangani error dari Firebase
      String errorMsg = "Terjadi kesalahan.";
      if (e.code == 'weak-password') {
        errorMsg = "Password terlalu lemah (Min. 6 karakter).";
      } else if (e.code == 'email-already-in-use') {
        errorMsg = "Email sudah terdaftar!";
      } else if (e.code == 'invalid-email') {
        errorMsg = "Format email tidak valid.";
      }
      _showError(errorMsg);
    } catch (e) {
      _showError("Koneksi gagal. Cek internet kamu.");
    } finally {
      // 7. Matikan loading
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Fungsi bantuan untuk menampilkan pesan error (SnackBar)
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  void dispose() {
    // Membersihkan memori saat halaman ditutup
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade600, Colors.white],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                const Icon(
                  Icons.person_add_alt_1_rounded,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Daftar Sahabat Pet",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      children: [
                        _buildTextField(
                          _emailController,
                          "Email Baru",
                          Icons.email_outlined,
                          false,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          _passwordController,
                          "Kata Sandi",
                          Icons.lock_outline,
                          true,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          _confirmPasswordController,
                          "Ulangi Sandi",
                          Icons.lock_reset,
                          true,
                        ),
                        const SizedBox(height: 30),
                        _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.green,
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 55),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onPressed: _signUp,
                                child: const Text(
                                  "DAFTAR SEKARANG",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    bool isPassword,
  ) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
