import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/logbook/counter_controller.dart';
import 'package:logbook_app_001/features/onboarding/onboarding_view.dart';

class CounterView extends StatefulWidget {
  
  final String username;

  const CounterView({super.key, required this.username});

  @override
  State<CounterView> createState() => _CounterViewState();
}


class _CounterViewState extends State<CounterView> {

  final CounterController _controller = CounterController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Logbook: ${widget.username}"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: (){
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title : const Text("Konfirmasi Logout"),
                  content: const Text ("Apakah Anda yakin? Data yang belum disimpan mungkin akan hilang."),
                  actions: [
                    //tombol batal
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(), 
                      child: const Text("Batal"),
                    ),

                    //tombol logout
                    TextButton(
                      onPressed: () {
                        
                        Navigator.pop(context);

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const OnboardingView()),
                          (route) => false, 
                        );
                      },
                      child: const Text("Ya, Keluar", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                );
              },
            );
          },
        ),
      
      ]
    ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text ("Selamat Datang, ${widget.username}!"),
              const SizedBox(height: 10),
              const Text("Total Hitungan Anda:"),
              Text(
                '${_controller.value}',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => setState(() => _controller.increment()),
          child: const Icon(Icons.add),
        ),
    );
  }
}
            