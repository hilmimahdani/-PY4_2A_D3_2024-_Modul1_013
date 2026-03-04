import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';
import 'package:logbook_app_001/services/mongo_services.dart';
import 'package:logbook_app_001/helpers/log_helper.dart';

class LogController {
    final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
    final ValueNotifier<List<LogModel>> filteredLogs = ValueNotifier([]);

    final String username;
  
    String get _storageKey => 'user_logs_data_$username';

    List<LogModel> get logs => logsNotifier.value;

    LogController(this.username){
      loadFromDisk();
    }

    Future<void> addLog(String title, String desc, String category) async {
      final newLog = LogModel(
        id: ObjectId(),
        username: username,
        title: title, 
        description: desc, 
        category: category, 
        date: DateTime.now(),
      );

      try {
        
        await MongoService().insertLog(newLog);
        
        final currentLogs = List<LogModel>.from(logsNotifier.value);
        currentLogs.add(newLog);
        logsNotifier.value = currentLogs;

        await LogHelper.writeLog(
          "SUCCESS: Tambah data dengan ID lokal",
          source : "log_controller.dart",
        );
      } catch (e) {
        await LogHelper.writeLog("ERROR: Gagal sinkronisasi Add - $e", level: 1);
      }
    }

    void searchLog(String query) {
      if (query.isEmpty) {
        filteredLogs.value = logsNotifier.value;
      } else {
        filteredLogs.value = logsNotifier.value
            .where((log) => log.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    }

    void _syncFiltered() {
      filteredLogs.value = logsNotifier.value;
    }

    Future <void> updateLog(int index, String newTitle, String newDesc, String category) async {

      final currentLogs = List<LogModel>.from(logsNotifier.value);
      final oldLog = currentLogs[index];
      
      final updateLog = LogModel(
        id: oldLog.id, 
        username: oldLog.username, 
        title: newTitle,
        description: newDesc,
        category: category,
        date: DateTime.now(),
      );

      try {
        
        await MongoService().updateLog(updateLog);

        currentLogs[index] = updateLog;
        logsNotifier.value = currentLogs;

        await LogHelper.writeLog(
          "SUCCESS: Sinkronisasi Update '${oldLog.title}' Berhasil",
          source: "log_controller.dart",
          level: 2,
        );

      } catch (e) {
        await LogHelper.writeLog(
          "ERROR: Gagal sinkronisasi Update - $e",
          source: "log_controller.dart",
          level: 1,
        );
      }
      _syncFiltered();
    }

    Future <void> removeLog(int index) async {
      final currentLogs = List<LogModel>.from(logsNotifier.value);
      final targetLog = currentLogs[index];

      try {
        if (targetLog.id == null) {
          throw Exception(
            "ID Log tidak ditemukan, tidak bisa menghapus di Cloud.",
          );
        }

        await MongoService().deleteLog(targetLog.id!);

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

      final cloudData = await MongoService().getLogsByUser(username);
      logsNotifier.value = cloudData;
  
    _syncFiltered();
    }
}
