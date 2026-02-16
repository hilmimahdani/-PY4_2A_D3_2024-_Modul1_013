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

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() async {
    await _controller.loadData(widget.username); 
    if (mounted){
      setState(() {
        _isLoading = false; 
      });
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Logout"),
          content: const Text("Apakah Anda yakin? Data yang belum disimpan mungkin akan hilang."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Batal"),
            ),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Logbook: ${widget.username}"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _handleLogout,
        ),
      ],
      ),


      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding (
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text("Total Hitungan Terakhir: "),
              Text(
                '${_controller.value}',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 20),
            
            //tombol kontrol
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                heroTag: "btnDec",
                onPressed: () async {
                  await _controller.decrement(widget.username);
                  setState(() {});
                },
                backgroundColor: Colors.redAccent,
                child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () async {
                    await _controller.reset(widget.username);
                    setState(() {});
                  },
                  child: const Text("reset"),
                ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  heroTag: "btnInc",
                  onPressed: () async {
                    await _controller.increment(widget.username);
                    setState(() {});
                  },
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.add),
                ),
            ],
          ),

          const SizedBox(height: 30),
          const Divider(),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Riwayat Aktivitas:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
          ),
          const SizedBox(height: 10),

          //List Riwayat
          Expanded(
            child: _controller.history.isEmpty
                ? const Center(child: Text("Belum ada aktivitas."))
                : ListView.builder(
                    itemCount: _controller.history.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: const Icon(Icons.history, size: 18),
                          title: Text(
                            _controller.history[index],
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
            