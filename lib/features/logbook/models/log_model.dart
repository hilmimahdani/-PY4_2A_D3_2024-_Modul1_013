import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';

class LogModel {
  final ObjectId? id;
  final String username;
  final String title;
  final String description;
  final String category;
  final DateTime date;

  LogModel({
    this.id,
    required this.username,
    required this.title,
    required this.date,
    required this.description,
    required this.category,
  });
  
  Map<String, dynamic> toMap() {
    return {
      '_id': id ?? ObjectId(),
      'username': username,
      'title': title,
      'description': description,
      'category': category,
      'date': date.toIso8601String(),
    };
  }

  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      id: map['_id'] is ObjectId ? map['_id'] as ObjectId: null,

      title: map['title'] ?? '',

      username : map['username'] ?? '',

      description: map['description'] ?? '',
      date: map['date'] is DateTime
      ? map['date'] as DateTime
      : map['date'] != null
        ? DateTime.parse(map['date'].toString())
        : DateTime.now(), 
      category: map['category'] ?? 'Umum', 
      
    );
  }

  Color getCategoryColor() {
    switch (category) {
      case 'Pekerjaan': return Colors.blue.shade100;
      case 'Urgent': return Colors.red.shade100;
      case 'Pribadi': return Colors.green.shade100;
      default: return Colors.white;
    }
  }

}
