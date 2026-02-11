import 'package:flutter/material.dart';
import 'counter_controller.dart';

class CounterView extends StatefulWidget {
  const CounterView({super.key});

  @override
  State<CounterView> createState() => _CounterViewState();
}


class _CounterViewState extends State<CounterView> {
  
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
                    onPressed: (){
                      setState(() => _controller.reset());
                       _stepInputController.text = "1";
                    },
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
                  const SizedBox(height: 10),//

              SizedBox(
                height: 150, 
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _controller.history.length,

                  itemBuilder: (context, index) {
                    return Card(child: Text(_controller.history[index]));
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