import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  ResetPasswordScreen({required this.email, required this.otp});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController otpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> resetPassword() async {
    final otpInput = otpController.text.trim();
    final newPassword = passwordController.text.trim();

    if (otpInput.isEmpty || newPassword.isEmpty) return;

    setState(() => isLoading = true);

    final url = Uri.parse('https://aeab-2409-40d2-100c-306b-10c7-3851-9d3d-f5c.ngrok-free.app/reset_password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'otp': otpInput,
          'new_password': newPassword,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password updated successfully!')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? 'Failed to update password')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.vpn_key, color: Colors.white),
            SizedBox(width: 8),
            Text('Reset Password', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: otpController,
                        decoration: InputDecoration(
                          labelText: 'Enter OTP',
                          labelStyle: TextStyle(color: Colors.indigo),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.key, color: Colors.indigo),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          labelStyle: TextStyle(color: Colors.indigo),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock, color: Colors.indigo),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: isLoading ? null : resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                          shadowColor: Colors.indigoAccent,
                        ),
                        child: isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('Reset Password', style: TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}