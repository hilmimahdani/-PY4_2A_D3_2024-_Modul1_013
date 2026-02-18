import 'package:shared_preferences/shared_preferences.dart';

class CounterController {
  int _counter = 0; 
  int _step = 1;
  List<String> _history = [];

  int get value => _counter; 
  int get step => _step;
  List<String> get history => _history;

  String _makeKeyCounter(String username) => 'counter_value_$username';
  String _makeKeyHistory(String username) => 'history_list_$username';

  Future<void> loadData(String username) async {
    final prefs = await SharedPreferences.getInstance();
    
    _counter = prefs.getInt(_makeKeyCounter(username)) ?? 0;
    
    _history = prefs.getStringList(_makeKeyHistory(username)) ?? [];
  }

  Future<void> _saveData(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_makeKeyCounter(username), _counter);
    await prefs.setStringList(_makeKeyHistory(username), _history);
  }


  void updateStep(int newStep) {
    _step = newStep;
  }

  void _addToHistory(String action, String username) {
    DateTime now = DateTime.now();
    String timestamp = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    
    String logMessage = "Pengguna $username $action pada jam $timestamp";

    _history.insert(0, logMessage);

    if (_history.length > 5) {
      _history.removeLast();
    }
  }

  Future<void> increment(String username) async {
    _counter += _step;
    _addToHistory("menambah $_step", username);
    await _saveData(username);
  } 

  Future<void> decrement(String username) async { 
    _counter -= _step;
    _addToHistory("mengurangi $_step", username);
    await _saveData(username);
  }

  Future<void> reset(String username) async {
    _counter = 0;
    _step = 1;
    _addToHistory("melakukan reset", username);
    await _saveData(username);
  }

}
