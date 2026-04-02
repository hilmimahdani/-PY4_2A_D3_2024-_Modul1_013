import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:logbook_app_001/features/logbook/log_controller.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';
import 'package:logbook_app_001/services/mongo_services.dart';

void main() {
  group('MODUL 4: SAVE DATA TO CLOUD SERVICE', () {
    late LogController controller;
    const String username = 'testUser';

    setUp(() {
      // Arrange: Setup SharedPreferences mock
      SharedPreferences.setMockInitialValues({});
      
      // Initialize controller
      controller = LogController(username);
    });

    // TEST CASE 01: Save Single Log to Cloud with Success
    test('TC01: Save single log to cloud service successfully', () async {
      // Arrange: Create a log model that will be synced to cloud
      final testLog = LogModel(
        id: ObjectId().oid,
        username: username,
        title: 'Server Issue Report',
        description: 'Critical server downtime detected',
        category: 'Software',
        date: DateTime.now(),
        authorId: username,
        teamId: 'team_dev',
        isSynced: false,
        isPublic: true,
      );

      // Act: Add log which should save to cloud
      await controller.addLogToCloud(
        testLog.title,
        testLog.description,
        testLog.category,
        testLog.isPublic,
      );

      // Assert: Verify log is in the local list
      expect(controller.logs.isNotEmpty, true,
          reason: 'Log should be added to local storage');
      expect(controller.logs.first.title, 'Server Issue Report',
          reason: 'Log title should match');
      expect(controller.logs.first.category, 'Software',
          reason: 'Log category should be Software');
      expect(controller.logs.first.isPublic, true,
          reason: 'Log isPublic should be true');
    });

    // TEST CASE 02: Save Multiple Logs to Cloud with Different Categories
    test('TC02: Save multiple logs with different categories to cloud', () async {
      // Arrange: Create multiple logs with different categories
      final logs = [
        (
          title: 'Hardware Maintenance',
          description: 'Scheduled server maintenance',
          category: 'Mechanical',
          isPublic: false,
        ),
        (
          title: 'Database Update',
          description: 'Migration to PostgreSQL v15',
          category: 'Software',
          isPublic: true,
        ),
        (
          title: 'Network Cable Replacement',
          description: 'Replaced faulty network cables',
          category: 'Electronical',
          isPublic: false,
        ),
      ];

      // Act: Add all logs
      for (var log in logs) {
        await controller.addLogToCloud(
          log.title,
          log.description,
          log.category,
          log.isPublic,
        );
      }

      // Assert: Verify all logs are saved
      expect(controller.logs.length, 3,
          reason: 'All three logs should be added');
      
      expect(
          controller.logs.firstWhere((log) => log.category == 'Mechanical').title,
          'Hardware Maintenance',
          reason: 'Mechanical log should be saved correctly');
      
      expect(
          controller.logs.firstWhere((log) => log.category == 'Software').title,
          'Database Update',
          reason: 'Software log should be saved correctly');
      
      expect(
          controller.logs.firstWhere((log) => log.category == 'Electronical').title,
          'Network Cable Replacement',
          reason: 'Electronical log should be saved correctly');
      
      expect(
          controller.logs.firstWhere((log) => log.category == 'Mechanical').isPublic,
          false,
          reason: 'Mechanical log isPublic should be false');
      
      expect(
          controller.logs.firstWhere((log) => log.category == 'Software').isPublic,
          true,
          reason: 'Software log isPublic should be true');
    });

    // TEST CASE 03: Handle Cloud Save Attempt with Multiple Log Types
    test('TC03: Save logs with different public/private status to cloud', () async {
      // Arrange: Create logs with mixed public/private status
      
      // Act: Add public and private logs
      await controller.addLogToCloud(
        'Public Documentation',
        'API documentation available for public',
        'Software',
        true,  // isPublic
      );

      await controller.addLogToCloud(
        'Internal Security Audit',
        'Confidential security audit report',
        'Software',
        false,  // isPrivate
      );

      await controller.addLogToCloud(
        'Equipment Repair Log',
        'Maintenance equipment repair',
        'Mechanical',
        false,  // isPrivate
      );

      // Assert: Verify all logs are saved with correct status
      expect(controller.logs.length, 3,
          reason: 'All three logs should be added');
      
      final publicLog = controller.logs.firstWhere((log) => log.title == 'Public Documentation');
      final privateSecurityLog = controller.logs.firstWhere((log) => log.title == 'Internal Security Audit');
      final privateMechanicalLog = controller.logs.firstWhere((log) => log.title == 'Equipment Repair Log');

      expect(publicLog.isPublic, true,
          reason: 'Public documentation should have isPublic=true');
      
      expect(privateSecurityLog.isPublic, false,
          reason: 'Internal audit should have isPublic=false');
      
      expect(privateMechanicalLog.isPublic, false,
          reason: 'Equipment repair log should have isPublic=false');
      
      expect(privateMechanicalLog.category, 'Mechanical',
          reason: 'Equipment repair log category should be Mechanical');
    });
  });
}
