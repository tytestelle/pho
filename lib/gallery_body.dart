import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'asset.dart';

class GalleryBody extends StatefulWidget {
  final bool useLocal;
  final String mode;

  const GalleryBody({Key? key, required this.useLocal, this.mode = 'photo'})
      : super(key: key);

  @override
  _GalleryBodyState createState() => _GalleryBodyState();
}

class _GalleryBodyState extends State<GalleryBody> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final model = context.read<AssetModel>();
    if (widget.useLocal) {
      if (widget.mode == 'photo') {
        model.getLocalPhotos();
      } else {
        model.getLocalFiles();
      }
    } else {
      if (widget.mode == 'photo') {
        model.getRemotePhotos();
      } else {
        model.getRemoteFiles();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AssetModel>();
    final assets = widget.useLocal ? model.localAssets : model.remoteAssets;

    if (model.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (assets.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.useLocal ? Icons.photo_library_outlined : Icons.cloud_off_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                widget.useLocal
                    ? '本机暂无可显示的媒体内容。'
                    : '云端内容暂未配置。',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              if (model.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  model.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemCount: assets.length,
      itemBuilder: (ctx, index) {
        final asset = assets[index];
        return _buildItem(asset);
      },
    );
  }

  Widget _buildItem(Asset asset) {
    if (widget.mode == 'photo') {
      final ImageProvider imageProvider = asset.local != null
          ? FileImage(asset.local!) as ImageProvider
          : NetworkImage(asset.remote!);
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getFileIcon(asset.fileExtension),
            size: 48,
            color: Colors.blue,
          ),
          const SizedBox(height: 4),
          Text(
            asset.displayName(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            asset.sizeString,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String? ext) {
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'apk':
        return Icons.android;
      case 'zip':
      case 'rar':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }
}
