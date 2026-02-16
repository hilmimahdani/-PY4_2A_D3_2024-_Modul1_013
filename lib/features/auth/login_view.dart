//login_view.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/auth/login_controller.dart';
import 'package:logbook_app_001/features/logbook/counter_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  
  final LoginController _controller = LoginController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  bool _isObscure = true; //buat hide/show password
  int _failedAttempts = 0; //hitung berapa kali gagal login
  bool _isLocked = false; //status kekunci atau ennga
  int _countdown = 0; //hitung mundur
  Timer? _timer; 

  void _handleLogin() {
    String user = _userController.text.trim();
    String pass = _passController.text.trim();

    if (user.isEmpty || pass.isEmpty){
      _showSnackBar("Username dan Password tidak boleh kosong!", Colors.orange);
      return;
    }

    bool isSuccess = _controller.login(user, pass);

    if (isSuccess) {
      setState(() {
        _failedAttempts = 0;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CounterView(username: user),
        ),
      );
    } else {
      setState(() {
        _failedAttempts++;
      });

      if (_failedAttempts >= 3) {
        _startLockdown();
        _showSnackBar("Login Gagal! Tunggu 10 detik.", Colors.red);
      } else {
        _showSnackBar("Login Gagal! Sisa percobaan ${3 - _failedAttempts}", Colors.red);
      }
    }
  }
      

  void _startLockdown() {
    setState(() {
      _isLocked = true;
      _countdown = 10;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        
        setState(() {
          _isLocked = false;
          _failedAttempts = 0; 
          timer.cancel();
        });
      } else {
        
        setState(() {
          _countdown--;
        });
      }
    });
  }


  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); 
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login Gatekeeper")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _userController,
              decoration: const InputDecoration(
                labelText: "Username",
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _passController,
              obscureText: _isObscure, // hide teks password
              decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscure ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: (){
                    setState(() {
                      _isObscure = !_isObscure; 
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                
                onPressed: _isLocked ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isLocked ? Colors.grey : Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  _isLocked ? "Tunggu $_countdown detik..." : "Masuk",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
