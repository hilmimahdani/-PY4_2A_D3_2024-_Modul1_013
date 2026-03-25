import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';
import 'package:logbook_app_001/helpers/log_helper.dart';

class MongoService {
  static final MongoService _instance = MongoService._internal();

  // Menggunakan nullable agar bisa mengecek status inisialisasi
  Db? _db;
  DbCollection? _collection;

  final String _source = "mongo_service.dart";

  factory MongoService() => _instance;
  MongoService._internal();

  Future<DbCollection> _getSafeCollection() async {
    if (_db == null || !_db!.isConnected || _collection == null) {
      await LogHelper.writeLog(
        "INFO: Koleksi belum siap, mencoba rekoneksi...",
        source: _source,
        level: 3,
      );
      await connect();
    }
    return _collection!;
  }

  Future<void> connect() async {
    try {
      final dbUri = dotenv.env['MONGODB_URI'];
      if (dbUri == null) throw Exception("MONGODB_URI tidak ditemukan di .env");

      _db = await Db.create('$dbUri&tls=true&safeAtlas=true');

      await _db!.open().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception(
            "Koneksi Timeout. Cek IP Whitelist (0.0.0.0/0) atau Sinyal HP.",
          );
        },
      );

      _collection = _db!.collection('logs');

      await LogHelper.writeLog(
        "DATABASE: Terhubung & Koleksi Siap",
        source: _source,
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "DATABASE: Gagal Koneksi - $e",
        source: _source,
        level: 1,
      );
      rethrow;
    }
  }

  Future<List<LogModel>> getLogsByUser(String username) async {
    try {
      final collection = await _getSafeCollection(); 

      await LogHelper.writeLog(
        "INFO: Fetching data from Cloud...",
        source: _source,
        level: 3,
      );

      final List<Map<String, dynamic>> data = await collection.find(where.eq('username', username)).toList();
      return data.map((json) => LogModel.fromMap(json)).toList();
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Fetch Failed - $e",
        source: _source,
        level: 1,
      );
      return [];
    }
  }


  Future<List<LogModel>> getLogsByTeam(String teamId) async {
    try {
      final collection = await _getSafeCollection(); 

      await LogHelper.writeLog(
        "INFO: Fetching data for Team: $teamId",
        source: "mongo_services.dart",
        level: 3,
      );

      final List<Map<String, dynamic>> data = await collection
          .find(where.eq('teamId', teamId))
          .toList();
          
      return data.map((json) => LogModel.fromMap(json)).toList();
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Fetch Failed - $e",
        source: "mongo_services.dart",
        level: 1,
      );
      return [];
    }
  }

    Future<List<LogModel>> getLogsWithPrivacy(String userId, String teamId) async {
      try {
        final collection = await _getSafeCollection();

        final query = {
          '\$or': [
            {'authorId': userId},  
            {'teamId': teamId, 'isPublic': true}  
          ]
        };

        final data = await collection.find(query).toList();

        await LogHelper.writeLog(
          "INFO: Fetched logs with privacy filter for user: $userId",
          source: _source,
          level: 3,
        );

        return data.map((json) => LogModel.fromMap(json)).toList();
      } catch (e) {
        await LogHelper.writeLog(
          "ERROR: Privacy Fetch Failed - $e",
          source: _source,
          level: 1,
        );
        return [];
      }
    }


  Future<void> insertLog(LogModel log) async {
    final collection = await _getSafeCollection();

    final map = log.toMap();
    map['isSynced'] = true;

    await collection.replaceOne(
      where.id(ObjectId.fromHexString(log.id!)),
      {
        ...log.toMap(),
        'isSynced': true,
      },
      upsert: true,
    );
    debugPrint("INSERT/UPSERT ID: ${log.id}");
    debugPrint("INSERT/UPSERT isSynced: true");

  }

  Future<void> updateLog(LogModel log) async {
    try {
      final collection = await _getSafeCollection();
      if (log.id == null){
        throw Exception("ID Log tidak ditemukan");
      }

      final updatedMap = log.toMap();
      updatedMap['isSynced'] = true;

      debugPrint("MONGO UPDATE DATA: $updatedMap");
      debugPrint("MONGO UPDATE isSynced: ${updatedMap['isSynced']}");

      await collection.replaceOne(
        where.id(ObjectId.fromHexString(log.id!)),
        updatedMap,
        upsert: true,
      );

      await LogHelper.writeLog(
        "DATABASE: Update '${log.title}' Berhasil",
        source: _source,
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "DATABASE: Update Gagal - $e",
        source: _source,
        level: 1,
      );
      rethrow;
    }
    debugPrint("MONGO UPDATE ID: ${log.id}");

  }

  Future<void> deleteLog(ObjectId id) async {
    try {
      final collection = await _getSafeCollection();
      await collection.remove(where.id(id));

      await LogHelper.writeLog(
        "DATABASE: Hapus ID $id Berhasil",
        source: _source,
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "DATABASE: Hapus Gagal - $e",
        source: _source,
        level: 1,
      );
      rethrow;
    }
  }

  Future<List<LogModel>> getLogsFiltered(String username) async {
  
    final query = where.eq('authorId', username).or(where.eq('isPublic', true));
    
    final collection = await _getSafeCollection();
    final results = await collection.find(query).toList();
    
    return results.map((json) => LogModel.fromMap(json)).toList();
  }
  

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      await LogHelper.writeLog(
        "DATABASE: Koneksi ditutup",
        source: _source,
        level: 2,
      );
    }
  }

    Future<bool> checkLogExists(String? id) async {
      final collection = await _getSafeCollection();

      final result = await collection.findOne(
        
        where.id(ObjectId.fromHexString(id!))
         
      );

      return result != null;
    }
}
