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
  final TextEditingController _stepController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _stepController.text = "1";
    _loadInitialData();
  }

  void _loadInitialData() async {
    await _controller.loadData(widget.username);
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  void _handleReset() {
    _controller.reset(widget.username);
    setState(() {}); 

    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Hitungan berhasil di-reset ke 0",
          style: TextStyle(color: Colors.black), 
        ),
        backgroundColor: Colors.blue[100], 
        duration: const Duration(seconds: 2), 
        behavior: SnackBarBehavior.floating, 
      ),
    );
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
        title: Text(
          "Logbook App: ${widget.username}",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), 
          ),
        
        
        backgroundColor: const Color(0xFF5CA3FF), 
        elevation: 0, 
        
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                 
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blueAccent),
                    ),
                    child: Text.rich(
                      TextSpan(
                        text: "${_getGreeting()}, ",
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                        children: [
                          TextSpan(
                            text: widget.username,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  
                  const Center(child: Text("Total Hitungan:")),
                  Center(
                    child: Text(
                      '${_controller.value}',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  
                  SizedBox(
                    height: 45,
                    child: TextField(
                      controller: _stepController,
                      keyboardType: TextInputType.number,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: const InputDecoration(
                        labelText: "Atur Nilai Step",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.show_chart, size: 20),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      onChanged: (value) {
                        int? newStep = int.tryParse(value);
                        if (newStep != null && newStep > 0) {
                          _controller.updateStep(newStep);
                        }
                      },
                    ),
                  ), 
                  const SizedBox(height: 10),

                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton(
                        mini: true,
                        heroTag: "btnDec",
                        onPressed: () async {
                          await _controller.decrement(widget.username);
                          setState(() {});
                        },
                        backgroundColor: Colors.redAccent,
                        elevation: 2,
                        child: const Icon(Icons.remove, size: 20),
                      ),
                      const SizedBox(width: 15),
                      SizedBox(
                        height: 35,
                        child: ElevatedButton(
                          onPressed: _handleReset,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.grey),
                          ),
                          
                          child: const Text("reset"),
                        ),
                      ),
                      const SizedBox(width: 15),
                      FloatingActionButton(
                        mini: true,
                        heroTag: "btnInc",
                        onPressed: () async {
                          await _controller.increment(widget.username);
                          setState(() {});
                        },
                        backgroundColor: Colors.green,
                        elevation: 2,
                        child: const Icon(Icons.add, size: 20),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),
                  const Divider(),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Riwayat Aktivitas:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 5),

                  
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      itemCount: _controller.history.length,
                      itemBuilder: (context, index) {
                        final logText = _controller.history[index];
                        Color cardColor;
                        Color textColor;
                        IconData iconData;

                        if (logText.contains("menambah")) {
                          cardColor = Colors.green[50]!;
                          textColor = Colors.green[500]!;
                          iconData = Icons.add_circle;
                        } else if (logText.contains("mengurangi")) {
                          cardColor = Colors.red[50]!;
                          textColor = Colors.red[500]!;
                          iconData = Icons.remove_circle;
                        } else {
                          cardColor = Colors.blue[50]!;
                          textColor = Colors.blue[500]!;
                          iconData = Icons.refresh;
                        }

                        return Card(
                          color: cardColor,
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            dense: true,
                            leading: Icon(iconData, size: 20, color: textColor),
                            title: Text(
                              logText,
                              style: TextStyle(
                                fontSize: 12,
                                color: textColor,
                                fontWeight: FontWeight.w500,
                              ),
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