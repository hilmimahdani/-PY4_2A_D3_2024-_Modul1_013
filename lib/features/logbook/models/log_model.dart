import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mongo_dart/mongo_dart.dart';

part 'log_model.g.dart'; 

@HiveType(typeId: 0)
class LogModel extends HiveObject {

  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final DateTime date;

  @HiveField(6)
  final String authorId; 

  @HiveField(7)
  final String teamId; 

  @HiveField(8)
  bool isSynced;

  @HiveField(9)
  final bool isPublic;
  

  LogModel({
    this.id,
    required this.username,
    required this.title,
    required this.date,
    required this.description,
    required this.category,
    required this.authorId,
    required this.teamId,
    this.isSynced = false,
    this.isPublic = false,
  });
  
  Map<String, dynamic> toMap() {
    return {
      '_id': id != null ? ObjectId.fromHexString(id!) : ObjectId(),
      'id' : id,
      'username': username,
      'title': title,
      'description': description,
      'category': category,
      'date': date.toIso8601String(),
      'authorId': authorId,
      'teamId': teamId,
      'isSynced': isSynced,
      'isPublic': isPublic,
    };
  }

  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      id: (map['_id'] as ObjectId?)?.oid, 
      title: map['title'] ?? '',
      username : map['username'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] is DateTime
      ? map['date'] as DateTime
      : map['date'] != null
        ? DateTime.parse(map['date'].toString())
        : DateTime.now(), 
      category: map['category'] ?? 'Mechanical', 
      authorId: map['authorId'] ?? 'unknown user', 
      teamId: map['teamId'] ?? 'no team', 
      isSynced: map['isSynced'] is bool ? map['isSynced'] : true, 
      isPublic: map['isPublic'] == true,
    );
  }

  Color getCategoryColor() {
    switch (category) {
      case 'Mechanical': return Colors.green.shade100;  
      case 'Electronical': return Colors.blue.shade100; 
      case 'Software': return Colors.purple.shade100;   
      default: return Colors.white;
    }
  }

}
