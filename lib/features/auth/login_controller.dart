//login_controller.dart
class LoginController {
  
  final Map<String, String> _userData = {
    "admin": "123",
    "hilmi": "hilmi123",
    "anita": "anita321",
  };

  bool login(String username, String password) {
    if (username.isEmpty || password.isEmpty) {
      return false;
    }

    if (_userData.containsKey(username) && _userData[username]  == password) { 
      return true;
    }

    return false;
  }
}
