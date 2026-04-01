import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logbook_app_001/features/counter/counter_controller.dart';

void main() {
  var actual, expected;

  group('Module 1 - CounterController', () {
    late CounterController controller;
    const username = "admin";

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      controller = CounterController();
      await controller.loadData(username); // FIX
    });

    test('TC01 - initial value should be 0', () {
      actual = controller.value;
      expected = 0;
      expect(actual, expected);
    });

    test('TC02 - setStep should change step value', () {
      controller.updateStep(5); // FIX
      actual = controller.step;
      expected = 5;
      expect(actual, expected);
    });

    test('TC03 - setStep should ignore negative value', () {
      controller.updateStep(3);
      controller.updateStep(-1);
      actual = controller.step;
      expected = 3;

      expect(actual, expected); // ini bakal FAIL
    });

    test('TC04 - increment should increase counter', () async {
      controller.updateStep(2);
      await controller.increment(username);
      actual = controller.value;
      expected = 2;
      expect(actual, expected);
    });

    test('TC05 - decrement should decrease counter', () async {
      controller.updateStep(2);
      await controller.increment(username);
      await controller.decrement(username);
      actual = controller.value;
      expected = 0;
      expect(actual, expected);
    });

    test('TC06 - decrement should not go below zero', () async {
      controller.updateStep(5);
      await controller.decrement(username);
      actual = controller.value;
      expected = 0;

      expect(actual, expected); // ini juga FAIL
    });

    test('TC07 - reset should set counter to zero', () async {
      await controller.increment(username);
      await controller.reset(username);
      actual = controller.value;
      expected = 0;
      expect(actual, expected);
    });

    test('TC08 - history should record actions', () async {
      controller.updateStep(1);
      await controller.increment(username);

      expect(controller.history.isNotEmpty, true);
      expect(controller.history.first.contains("menambah"), true);
    });

    test('TC09 - history should not exceed 5 items', () async {
      controller.updateStep(1);

      for (int i = 0; i < 6; i++) {
        await controller.increment(username);
      }

      actual = controller.history.length;
      expected = 5;

      expect(actual, expected);
    });

    test('TC10 - counter should persist', () async {
      controller.updateStep(3);
      await controller.increment(username);

      final newController = CounterController();
      await newController.loadData(username);

      actual = newController.value;
      expected = 3;

      expect(actual, expected);
    });
  });
}