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

  final List<Map<String, String>> _onboardingData = [
    {
      "image": "assets/images/onboarding1.png", 
      "title": "Catat Aktivitas",
      "desc": "Selamat datang di aplikasi Logbook. Kelola catatanmu dengan mudah.",
    },
    {
      "image": "assets/images/onboarding2.png",
      "title": "Pantau Progress",
      "desc": "Pantau semua aktivitas harianmu dalam satu genggaman.",
    },
    {
      "image": "assets/images/onboarding3.png",
      "title": "Mulai Sekarang",
      "desc": "Siap untuk memulai? Klik tombol di bawah untuk login.",
    },
  ];

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
    final currentData = _onboardingData[step - 1];

    return Scaffold(
     
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),

              Expanded(
                flex: 5,
                child: Image.asset(
                  currentData["image"]!,

                  width: double.infinity, 
                  // Mengatur agar gambar menyesuaikan ruang tanpa terpotong
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace){
                    return const Icon(Icons.image_not_supported, size: 100, color: Colors.grey);
                  },
                ),
              ),

              const SizedBox(height: 20),

              Text(
                currentData["title"]!,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                currentData["desc"]!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const Spacer(),

              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: step == (index + 1) ? 24 : 12, 
                    height: 12,
                    decoration: BoxDecoration(
                      color: step == (index + 1) ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 40),

              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(step < 3 ? "Lanjut" : "Mulai"),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
