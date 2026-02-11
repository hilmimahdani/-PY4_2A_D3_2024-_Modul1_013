class CounterController {
  int _counter = 0; 
  int _step = 1;

  final List<String> _history = [];

  int get value => _counter; 
  int get step => _step;

  List<String> get history => _history;

  void updateStep(int newStep) {
    _step = newStep;
  }

  void _addToHistory(String action) {
    DateTime now = DateTime.now();
    String timestamp = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    
    _history.insert(0, "$action pada jam $timestamp");

    if (_history.length > 5) {
      _history.removeLast();
    }
  }

  void increment() {
    _counter += _step;
    _addToHistory("User menambah nilai sebesar $_step");
  } 

  void decrement() { 
    _counter -= _step;
    _addToHistory("User mengurangi nilai sebesar $_step");
  }

  void reset() {
    _counter = 0;
    _step = 1;
    _addToHistory("User melakukan Reset");
  }

}
