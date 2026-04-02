import 'package:flutter_test/flutter_test.dart';
import 'package:logbook_app_001/features/auth/login_controller.dart';

void main() {
  dynamic actual, expected;

  group('Module 2 - Authentication (LoginController)', () {
    late LoginController controller;

    setUp(() {
      controller = LoginController();
    });

    test('TC01 - login should return true with valid credentials', () {
      // Arrange
      String username = "admin";
      String password = "123";

      // Act
      actual = controller.login(username, password);

      // Assert
      expected = true;
      expect(actual, expected);
    });

    test('TC02 - login should return false with incorrect password', () {
      // Arrange
      String username = "admin";
      String password = "wrong_password";

      // Act
      actual = controller.login(username, password);

      // Assert
      expected = false;
      expect(actual, expected);
    });

    test('TC03 - login should return false with empty username', () {
      // Arrange
      String username = "";
      String password = "123";

      // Act
      actual = controller.login(username, password);

      // Assert
      expected = false;
      expect(actual, expected);
    });
  });
}
