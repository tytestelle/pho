import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:photo_manager/photo_manager.dart';

class Asset {
  File? local;
  String? remote;
  bool isImage = false;
  bool isVideo = false;
  String? fileExtension;
  String? fileName;
  int? size;

  Asset({this.local, this.remote}) {
    _parse();
  }

  void _parse() {
    String? fullPath;
    if (local != null) {
      fullPath = local!.path;
      size = local!.lengthSync();
    } else if (remote != null) {
      fullPath = remote!;
    }
    if (fullPath == null) return;

    fileName = path.basename(fullPath);
    fileExtension = path.extension(fullPath).toLowerCase().replaceFirst('.', '');

    const imageExts = {'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'heic', 'heif'};
    const videoExts = {'mp4', 'avi', 'mov', 'mkv', 'wmv', 'flv', '3gp'};

    if (imageExts.contains(fileExtension)) {
      isImage = true;
      isVideo = false;
    } else if (videoExts.contains(fileExtension)) {
      isVideo = true;
      isImage = false;
    } else {
      isImage = false;
      isVideo = false;
    }
  }

  bool get isFile => !isImage && !isVideo;

  String displayName() => fileName ?? 'unknown';

  String get sizeString {
    if (size == null) return '';
    if (size! < 1024) return '$size B';
    if (size! < 1024 * 1024) return '${(size! / 1024).toStringAsFixed(1)} KB';
    if (size! < 1024 * 1024 * 1024) return '${(size! / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(size! / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Asset &&
          runtimeType == other.runtimeType &&
          local?.path == other.local?.path &&
          remote == other.remote;

  @override
  int get hashCode => (local?.path ?? remote).hashCode;
}

class AssetModel extends ChangeNotifier {
  List<Asset> localAssets = [];
  List<Asset> remoteAssets = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> getLocalPhotos() async {
    await _loadLocalAssets(RequestType.image);
  }

  Future<void> getLocalFiles() async {
    await _loadLocalAssets(RequestType.common);
  }

  Future<void> getRemotePhotos() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 200));
    remoteAssets = [];
    errorMessage = '云端相册尚未配置，请先完成存储设置。';
    isLoading = false;
    notifyListeners();
  }

  Future<void> getRemoteFiles() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 200));
    remoteAssets = [];
    errorMessage = '云端文件尚未配置，请先完成存储设置。';
    isLoading = false;
    notifyListeners();
  }

  Future<void> _loadLocalAssets(RequestType requestType) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final permission = await PhotoManager.requestPermissionExtend();
    if (permission != PermissionState.authorized) {
      isLoading = false;
      errorMessage = '需要相册权限才能查看媒体内容。';
      localAssets = [];
      notifyListeners();
      return;
    }

    try {
      final paths = await PhotoManager.getAssetPathList(type: requestType, hasAll: true);
      final result = <Asset>[];

      for (final pathEntity in paths) {
        final assets = await pathEntity.getAssetListRange(start: 0, end: 200);
        for (final assetEntity in assets) {
          if (requestType == RequestType.image && assetEntity.type != AssetType.image) {
            continue;
          }
          final file = await assetEntity.file;
          if (file != null) {
            result.add(Asset(local: file));
          }
        }
      }

      localAssets = result;
    } catch (e) {
      localAssets = [];
      errorMessage = '加载本地媒体失败: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
