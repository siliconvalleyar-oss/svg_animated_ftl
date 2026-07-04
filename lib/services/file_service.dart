import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FileService {
  static Future<String> get _localPath async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } catch (e) {
      debugPrint('Error getting local path: $e');
      return '';
    }
  }

  static Future<File> _localFile(String name) async {
    final path = await _localPath;
    return File('$path/$name');
  }

  static Future<String> readFile(String fileName) async {
    try {
      final file = await _localFile(fileName);
      if (!await file.exists()) return '';
      return await file.readAsString();
    } catch (e) {
      debugPrint('Error reading file: $e');
      return '';
    }
  }

  static Future<bool> writeFile(String fileName, String content) async {
    try {
      final file = await _localFile(fileName);
      await file.writeAsString(content, flush: true);
      return true;
    } catch (e) {
      debugPrint('Error writing file: $e');
      return false;
    }
  }

  static Future<bool> deleteFile(String fileName) async {
    try {
      final file = await _localFile(fileName);
      if (await file.exists()) {
        await file.delete();
      }
      return true;
    } catch (e) {
      debugPrint('Error deleting file: $e');
      return false;
    }
  }

  static Future<bool> fileExists(String fileName) async {
    try {
      final file = await _localFile(fileName);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
}
