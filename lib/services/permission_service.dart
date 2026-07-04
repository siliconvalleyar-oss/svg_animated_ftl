import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestStoragePermission() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.storage.status;
        if (status.isGranted) return true;
        final result = await Permission.storage.request();
        return result.isGranted;
      }
      if (Platform.isIOS) return true;
      return false;
    } catch (e) {
      debugPrint('Error requesting permission: $e');
      return false;
    }
  }

  static Future<bool> requestPhotosPermission() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final status = await Permission.photos.status;
        if (status.isGranted) return true;
        final result = await Permission.photos.request();
        return result.isGranted;
      }
      return false;
    } catch (e) {
      debugPrint('Error requesting photos permission: $e');
      return false;
    }
  }
}
