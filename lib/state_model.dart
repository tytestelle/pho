import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'asset.dart';

class AssetModel extends ChangeNotifier {
  List<Asset> localAssets = [];
  List<Asset> remoteAssets = [];

  // 加载本地相册（图片/视频）
  Future<void> getLocalPhotos() async {
    // 这里应使用原生插件或 MediaStore 获取媒体文件
    // 为简化演示，使用 path_provider 遍历目录（仅示例）
    final dir = await getApplicationDocumentsDirectory();
    final files = dir.listSync(recursive: true).whereType<File>();
    localAssets = files
        .map((f) => Asset(local: f))
        .where((a) => a.isImage || a.isVideo)
        .toList();
    notifyListeners();
  }

  // 加载本地所有文件
  Future<void> getLocalFiles() async {
    final dir = await getApplicationDocumentsDirectory();
    final files = dir.listSync(recursive: true).whereType<File>();
    localAssets = files.map((f) => Asset(local: f)).toList();
    notifyListeners();
  }

  // 加载云端相册（示例）
  Future<void> getRemotePhotos() async {
    // 模拟从云端获取 JSON 数据
    final response = await http.get(Uri.parse('https://your-api.com/photos'));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      remoteAssets = data.map((item) => Asset(remote: item['url'])).toList();
      notifyListeners();
    }
  }

  // 加载云端所有文件
  Future<void> getRemoteFiles() async {
    final response = await http.get(Uri.parse('https://your-api.com/files'));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      remoteAssets = data.map((item) => Asset(remote: item['url'])).toList();
      notifyListeners();
    }
  }
}
