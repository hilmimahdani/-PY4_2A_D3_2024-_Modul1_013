import 'package:flutter/material.dart';

class LogModel {
  final String title;
  final String date;
  final String description;
  final String category;

  LogModel({
    required this.title,
    required this.date,
    required this.description,
    required this.category,
  });
  

  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      title: map['title'] ?? '',
      date: map['date'] ?? '',
      description: map['description'],
      category: map['category'] ?? 'Umum',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date,
      'description': description,
      'category': category,
    };
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
