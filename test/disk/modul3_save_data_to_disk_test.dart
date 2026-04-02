import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';
import 'package:logbook_app_001/features/logbook/log_controller.dart';
import 'package:mongo_dart/mongo_dart.dart';

void main() {
  dynamic actual, expected;

  group('Module 3 - Save Data to Disk (LogController saveToDisk)', () {
    late LogController controller;
    const username = "admin";

    setUp(() async {
      // Setup mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      
      // Create LogController without calling loadFromDisk
      controller = LogController(username);
    });

    test('TC01 - saveToDisk should persist log with isPublic false to disk', () async {
      // Arrange (Setup)
      final log = LogModel(
        id: ObjectId().oid,  // Generate valid ObjectId
        username: username,
        title: "Maintenance Report",
        description: "Daily maintenance check",
        category: "Mechanical",
        date: DateTime(2024, 4, 2, 10, 30),
        authorId: username,
        teamId: "team_xyz",
        isSynced: false,
        isPublic: false,
      );
      controller.logsNotifier.value = [log];

      // Act (Exercise)
      await controller.saveToDisk();

      // Assert (Verify)
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('user_logs_data_$username');
      
      actual = savedData != null;
      expected = true;
      expect(actual, expected);
      expect(savedData!.contains("Maintenance Report"), true);
      expect(savedData.contains("\"isPublic\":false"), true);
    });

    test('TC02 - saveToDisk should persist log with isPublic true to disk', () async {
      // Arrange (Setup)
      final log = LogModel(
        id: ObjectId().oid,  // Generate valid ObjectId
        username: username,
        title: "Public Report",
        description: "Shared maintenance check",
        category: "Software",
        date: DateTime(2024, 4, 2, 14, 45),
        authorId: username,
        teamId: "team_xyz",
        isSynced: true,
        isPublic: true,
      );
      controller.logsNotifier.value = [log];

      // Act (Exercise)
      await controller.saveToDisk();

      // Assert (Verify)
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('user_logs_data_$username');
      
      actual = savedData != null;
      expected = true;
      expect(actual, expected);
      expect(savedData!.contains("Public Report"), true);
      expect(savedData.contains("\"isPublic\":true"), true);
    });

    test('TC03 - saveToDisk should persist multiple logs with different categories to disk', () async {
      // Arrange (Setup)
      final logs = [
        LogModel(
          id: ObjectId().oid,  // Generate valid ObjectId
          username: username,
          title: "Mechanical Log",
          description: "Mechanical maintenance",
          category: "Mechanical",
          date: DateTime.now(),
          authorId: username,
          teamId: "team_xyz",
          isSynced: false,
          isPublic: false,
        ),
        LogModel(
          id: ObjectId().oid,  // Generate valid ObjectId
          username: username,
          title: "Software Log",
          description: "Software update",
          category: "Software",
          date: DateTime.now(),
          authorId: username,
          teamId: "team_xyz",
          isSynced: true,
          isPublic: true,
        ),
        LogModel(
          id: ObjectId().oid,  // Generate valid ObjectId
          username: username,
          title: "Electrical Log",
          description: "Electrical check",
          category: "Electronical",
          date: DateTime.now(),
          authorId: username,
          teamId: "team_xyz",
          isSynced: false,
          isPublic: false,
        ),
      ];
      controller.logsNotifier.value = logs;

      // Act (Exercise)
      await controller.saveToDisk();

      // Assert (Verify)
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('user_logs_data_$username');
      
      actual = savedData != null;
      expected = true;
      expect(actual, expected);
      expect(savedData!.contains("Mechanical Log"), true);
      expect(savedData.contains("Software Log"), true);
      expect(savedData.contains("Electrical Log"), true);
    });
  });
}
