import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String selectedRole = 'student';

  Future<void> signupUser() async {
    String email = emailController.text;
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    // Connect with backend
    final url = Uri.parse('https://aeab-2409-40d2-100c-306b-10c7-3851-9d3d-f5c.ngrok-free.app/signup');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password, 'role': selectedRole}),
      );
      if (response.statusCode == 200) {
        // Signup successful
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup successful')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        print('Signup failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        String msg = 'Signup failed';
        try {
          final respJson = json.decode(response.body);
          if (respJson is Map && respJson.containsKey('message')) {
            msg = respJson['message'];
          }
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } catch (e) {
      print('Signup error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
            Icon(Icons.person_add, color: Colors.white),
            SizedBox(width: 8),
            Text('Sign Up', style: TextStyle(color: Colors.white)),
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
                      SizedBox(height: 10),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.indigo),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email, color: Colors.indigo),
                        ),
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.indigo),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock, color: Colors.indigo),
                        ),
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          labelStyle: TextStyle(color: Colors.indigo),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock_outline, color: Colors.indigo),
                        ),
                      ),
                      SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: InputDecoration(
                          labelText: 'Select Role',
                          labelStyle: TextStyle(color: Colors.indigo),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.group, color: Colors.indigo),
                        ),
                        items: [
                          DropdownMenuItem(value: 'student', child: Text('Student')),
                          DropdownMenuItem(value: 'admin', child: Text('Admin')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value!;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: signupUser,
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
                        child: Text('Sign Up', style: TextStyle(fontSize: 18)),
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