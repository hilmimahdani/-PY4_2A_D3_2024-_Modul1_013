import 'package:flutter/material.dart';
import 'counter_controller.dart';

class CounterView extends StatefulWidget {
  const CounterView({super.key});

  @override
  State<CounterView> createState() => _CounterViewState();
}


class _CounterViewState extends State<CounterView> {

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Reset"),
          content: const Text("Apakah kamu yakin ingin menghapus semua hitungan dan riwayat?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                setState(() {
                  _controller.reset();
                  _stepInputController.text = "1";
                });
                Navigator.pop(context); 
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Data berhasil di-reset!")),
                );
              },
              child: const Text("Ya, Reset", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  final CounterController _controller = CounterController();

  final TextEditingController _stepInputController = TextEditingController(text: "1");


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Logbook: Counter")),
      body: SingleChildScrollView(
        child: Padding(
        padding : const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text ("Total Hitungan:"),
              Text('${_controller.value}',
                style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
              ),
            
              const SizedBox(height: 20),
            
              SizedBox(
                width: 200,
                  child: TextField(
                    controller: _stepInputController,
                    keyboardType: TextInputType.number, 
                    decoration: const InputDecoration(
                      labelText: "Besar Step",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.bolt),
                    ),  
                    onChanged: (value) {
                    
                      int? parsedValue = int.tryParse(value);
                      if (parsedValue != null) {
                        _controller.updateStep(parsedValue);
                      }
                    },
                  ),
              ),
            
              const SizedBox(height: 20),
            
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    heroTag: "btn_dec",
                    onPressed: () => setState(() => _controller.decrement()), 
                    child: const Icon(Icons.remove),
                  ),
                  const SizedBox(width: 10),
                  FloatingActionButton(
                    heroTag: "btn_res",
                    onPressed: _showResetDialog,
                    child: const Icon(Icons.refresh),
                  ),

                  const SizedBox(width: 10),
                  FloatingActionButton(
                    heroTag: "btn_inc",
                    onPressed: () => setState(() => _controller.increment()),
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
                  const SizedBox(height: 30),

                  const Divider(),
                  const Text("Riwayat 5 Aktivitas Terakhir:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),//

              SizedBox(
                height: 300, 
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _controller.history.length,

                  itemBuilder: (context, index) {
                    String log = _controller.history[index];
                    Color itemColor = Colors.grey;

                    if (log.contains("menambah")) {
                      itemColor = Colors.green;
                    } else if (log.contains("mengurangi")) {
                      itemColor = Colors.red;
                    } else if (log.contains("Reset")) {
                      itemColor = Colors.blue;
                    }

                    return Card(
                      child: ListTile(
                        leading: Icon(
                          log.contains("menambah") 
                              ? Icons.add_circle 
                              : (log.contains("mengurangi") ? Icons.remove_circle : Icons.refresh),
                          color: itemColor, 
                        ), 
                        title: Text( 
                          log, 
                          style: TextStyle(color: itemColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}