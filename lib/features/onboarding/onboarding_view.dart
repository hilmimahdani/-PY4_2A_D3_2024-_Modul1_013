// onboarding_view.dart
import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/auth/login_view.dart'; 

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  int step = 1;

  void _nextStep() {
    setState(() {
      if (step < 3) {
        step++;
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginView()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Welcome")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              CircleAvatar(
                radius: 50,
                child: Text("$step", style: const TextStyle(fontSize: 40)),
              ),
              const SizedBox(height: 24),
              
              Text(
                "Langkah Ke-$step",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                _getStepDescription(step),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _nextStep,
                  child: Text(step < 3 ? "Next" : "Get Started"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStepDescription(int step) {
    switch (step) {
      case 1:
        return "Selamat datang di aplikasi Logbook.";
      case 2:
        return "Klik Next untuk selanjutnya";
      case 3:
        return "Klik Next untuk selanjutnya.";
      default:
        return "";
    }
  }
}