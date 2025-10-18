import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String message = '';

  void signUp() async {
    try {
      await AuthService().signUp(emailController.text, passwordController.text);
      setState(() => message = 'Sign up successful!');
    } catch (e) {
      setState(() => message = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: signUp, child: const Text('Sign Up')),
            const SizedBox(height: 8),
            Text(message),
            TextButton(
                onPressed: () => Navigator.pop(context), child: const Text('Back to Login'))
          ],
        ),
      ),
    );
  }
}
