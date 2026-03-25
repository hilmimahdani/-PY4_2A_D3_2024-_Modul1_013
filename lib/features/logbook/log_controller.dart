import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';
import 'package:logbook_app_001/services/mongo_services.dart';
import 'package:logbook_app_001/helpers/log_helper.dart';
import 'package:logbook_app_001/services/access_control_service.dart';

class LogController {
    final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
    final ValueNotifier<List<LogModel>> filteredLogs = ValueNotifier([]);

    final String username;
  
    String get _storageKey => 'user_logs_data_$username';

    List<LogModel> get logs => logsNotifier.value;

    LogController(this.username){
      loadFromDisk();
    }

    /// 2. ADD DATA (Instant Local + Background Cloud)
    Future<void> addLog(String title, String desc, String category, bool isPublic) async {
      // 1. Siapkan data baru
      final newLog = LogModel(
        id: ObjectId().oid, // PENTING: Gunakan String .oid untuk Hive
        username: username,
        title: title,
        description: desc,
        category: category,
        date: DateTime.now(), 
        authorId: username, 
        teamId: 'team_xyz', 
        isSynced: false, 
        isPublic: isPublic,
      );

      //Simpan ke Hive (Offline & Instan)
      final box = Hive.box<LogModel>('offline_logs'); 
      await box.put(newLog.id, newLog);

      final currentLogs = List<LogModel>.from(logsNotifier.value);
      currentLogs.add(newLog);
      logsNotifier.value = currentLogs;
      _syncFiltered(); 

      try {
      
        await MongoService().insertLog(newLog); 

        newLog.isSynced = true;

        await box.put(newLog.id, newLog); 
        
        final updatedLogs = List<LogModel>.from(logsNotifier.value);
        final index = updatedLogs.indexWhere((log) => log.id == newLog.id);
        if (index != -1) updatedLogs[index] = newLog;
        logsNotifier.value = updatedLogs;
        _syncFiltered();

        
      } catch (e) {
        newLog.isSynced = false; 
        await box.put(newLog.id, newLog); 
      }
    }


    Future<void> syncOfflineData() async {

      final box = Hive.box<LogModel>('offline_logs');
      
      final unsyncedLogs = box.values.where((log) => log.isSynced == false).toList();
      debugPrint("UNSYNCED COUNT: ${unsyncedLogs.length}");

      for (var log in unsyncedLogs) {
        debugPrint("SYNCING: ${log.title} | ID: ${log.id}");
        debugPrint("TITLE: ${log.title}");
        debugPrint("BEFORE isSynced: ${log.isSynced}");
        try {
          await MongoService().updateLog(log);

          log.isSynced = true; 

          await box.put(log.id, log);

          debugPrint("AFTER isSynced: ${log.isSynced}");
          debugPrint("SUCCESS SYNC: ${log.title}");

          final exists = await MongoService().checkLogExists(log.id);
          debugPrint("CHECK EXISTS RESULT: $exists");

        } catch (e) {
          
          log.isSynced = false; 
          await box.put(log.id, log); 
          debugPrint("FAILED SYNC: ${log.title} -> $e");
        }
      }

      debugPrint("SYNC DONE -> REFRESH UI");

      logsNotifier.value = List.from(box.values);
      _syncFiltered();
    }


    void searchLog(String query) {
      if (query.isEmpty) {
        filteredLogs.value = logsNotifier.value;
      } else {
        final lowerQuery = query.toLowerCase();
        filteredLogs.value = logsNotifier.value
            .where((log) =>
                log.title.toLowerCase().contains(lowerQuery) ||
                log.description.toLowerCase().contains(lowerQuery) ||
                log.category.toLowerCase().contains(lowerQuery))
            .toList();
      }
    }

    void _syncFiltered() {
      filteredLogs.value = logsNotifier.value;
    }

    Future <void> updateLog(int index, String newTitle, String newDesc, String category, bool isPublic) async {

      final currentLogs = List<LogModel>.from(logsNotifier.value);
      final oldLog = currentLogs[index];
      
      final updatedLog = LogModel(
        id: oldLog.id, 
        username: oldLog.username, 
        title: newTitle,
        description: newDesc,
        category: category,
        isPublic: isPublic,
        date: DateTime.now(),
        authorId: oldLog.authorId,
        teamId: oldLog.teamId,
        isSynced: false,
      );

      try {
        
        await MongoService().updateLog(updatedLog);

        updatedLog.isSynced = true;

        currentLogs[index] = updatedLog;
        logsNotifier.value = currentLogs;

        await LogHelper.writeLog(
          "SUCCESS: Sinkronisasi Update '${oldLog.title}' Berhasil",
          source: "log_controller.dart",
          level: 2,
        );

      } catch (e) {
        updatedLog.isSynced = false;
        final box = Hive.box<LogModel>('offline_logs');

        await box.put(updatedLog.id, updatedLog); 

        await LogHelper.writeLog(
          "ERROR: Gagal sinkronisasi Update - $e",
          source: "log_controller.dart",
          level: 1,
        );
      }
      _syncFiltered();
      debugPrint("FINAL STATUS UPDATE: ${updatedLog.title} -> ${updatedLog.isSynced}");
    }

    Future <void> removeLog(int index) async {
      final currentLogs = List<LogModel>.from(logsNotifier.value);
      final targetLog = currentLogs[index];
      final box = Hive.box<LogModel>('offline_logs');

      String userRole = (username.toLowerCase () == 'admin') ? 'Ketua': 'Anggota';
     
      if (!AccessControlService.canPerform(
          userRole, 
          AccessControlService.actionDelete, 
          isOwner: targetLog.authorId == username)) {
            
        await LogHelper.writeLog(
          "SECURITY BREACH: Unauthorized delete attempt pada log '${targetLog.title}'", 
          source: "log_controller.dart",
          level: 1
        );
        return; 
      }

      try {
        if (targetLog.id == null) {
          throw Exception(
            "ID Log tidak ditemukan, tidak bisa menghapus di Cloud.",
          );
        }

        await MongoService().deleteLog(ObjectId.fromHexString(targetLog.id!));

        await box.delete(targetLog.id); 
       
        currentLogs.removeAt(index);
        logsNotifier.value = currentLogs;

        await LogHelper.writeLog(
          "SUCCESS: Sinkronisasi Hapus '${targetLog.title}' Berhasil",
          source: "log_controller.dart",
          level: 2,
        );
      } catch (e) {
        await LogHelper.writeLog(
          "ERROR: Gagal sinkronisasi Hapus - $e",
          source: "log_controller.dart",
          level: 1,
        );
      }
      _syncFiltered();
      
    }

    Future<void> saveToDisk() async {
      final prefs = await SharedPreferences.getInstance();
      final String encodedData = jsonEncode(logsNotifier.value.map((log) => log.toMap()).toList());
      await prefs.setString(_storageKey, encodedData);
    }


    Future<void> loadFromDisk() async {
      final box = Hive.box<LogModel>('offline_logs');
      
      final localData = box.values.where((log) => log.username == username).toList();
      logsNotifier.value = localData;
      _syncFiltered();

      try {
        await syncOfflineData();

        final cloudData = await MongoService().getLogsFiltered(username);

        debugPrint("CLOUD COUNT: ${cloudData.length}");
       
       final updatedLocalData = box.values.where((log) => log.username == username).toList();
      debugPrint("LOCAL COUNT: ${updatedLocalData.length}");
      
      final updatedList = <LogModel>[];

      for (var cloud in cloudData) {
        final local = updatedLocalData.firstWhere(
          (l) => l.id == cloud.id,
          orElse: () => cloud,
        );

        debugPrint("MERGE ID: ${local.id}");
        debugPrint("BEFORE FIX: ${local.isSynced}");

        local.isSynced = true;
        await box.put(local.id, local);

      debugPrint("AFTER FIX: ${local.isSynced}");

        updatedList.add(local);
      }

        final cloudIds = cloudData.map((e) => e.id).toSet();

        final unsynced = updatedLocalData.where((l) => !cloudIds.contains(l.id)).toList();

        logsNotifier.value = [...updatedList, ...unsynced];

        _syncFiltered();

        for (var log in box.values) {
          debugPrint("FINAL HIVE: ${log.title} | isSynced: ${log.isSynced}");
        }

        await LogHelper.writeLog("SUCCESS: Data Cloud & Lokal berhasil digabung", source: "log_controller", level: 2);
      } catch (e) {
        
        await LogHelper.writeLog("OFFLINE: Gagal ambil Cloud, pakai cache lokal", source: "log_controller", level: 1);
      }
    }

    /// Load logs dengan privacy filter dari Hive
    Future<void> loadLogsWithPrivacy(String teamId) async {
      try {
        final box = Hive.box<LogModel>('offline_logs');
        
        final allLogs = box.values.toList();
        
        final filteredLogs = allLogs.where((log) {
          return log.authorId == username || 
                (log.teamId == teamId && log.isPublic);
        }).toList();

        logsNotifier.value = filteredLogs;
        _syncFiltered();
      } catch (e) {
        await LogHelper.writeLog(
          "ERROR: Load privacy logs failed - $e",
          source: "log_controller.dart",
          level: 1,
        );
      }
    }

}
