import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'asset.dart';
import 'state_model.dart';

class GalleryBody extends StatefulWidget {
  final bool useLocal; // true=本地，false=云端
  final String mode;   // 'photo' 或 'file'

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

    return Scaffold(
      body: assets.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
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
            ),
    );
  }

  Widget _buildItem(Asset asset) {
    if (widget.mode == 'photo') {
      // 照片模式：显示图片或视频缩略图
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: asset.local != null
                ? FileImage(asset.local!)
                : NetworkImage(asset.remote!),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      // 文件模式：显示文件图标 + 文件名
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
