import 'dart:io';
import 'package:path/path.dart' as path;

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

  // 从文件名或路径解析信息
  void _parse() {
    String? fullPath;
    if (local != null) {
      fullPath = local!.path;
      size = local!.lengthSync();
    } else if (remote != null) {
      fullPath = remote!;
      // 云端文件大小可能需要额外获取，暂不处理
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

  // 判断是否为文件（非图片/视频）
  bool get isFile => !isImage && !isVideo;

  // 获取显示名称
  String displayName() => fileName ?? 'unknown';

  // 获取文件大小字符串
  String get sizeString {
    if (size == null) return '';
    if (size! < 1024) return '$size B';
    if (size! < 1024 * 1024) return '${(size! / 1024).toStringAsFixed(1)} KB';
    if (size! < 1024 * 1024 * 1024) return '${(size! / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(size! / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // 判断两个 Asset 是否相同（基于路径）
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
