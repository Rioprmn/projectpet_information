import 'package:flutter/material.dart';
import 'package:pet_information/services/auth_service.dart';
import 'package:pet_information/views/home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login Pet Information")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                var user = await _authService.login(_emailController.text, _passwordController.text);
                if (user != null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login Berhasil!")));
                  Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => const HomePage())
                );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login Gagal! Cek email/pass atau daftar dulu.")));
                }
              },
              child: const Text("Login"),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
              },
              child: const Text("Belum punya akun? Daftar di sini"),
            ),
          ],
        ),
      ),
    );
  }
}