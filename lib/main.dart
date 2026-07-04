import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'gallery_body.dart';
import 'state_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AssetModel(),
      child: MaterialApp(
        title: 'PHO',
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    GalleryBody(useLocal: true, mode: 'photo'),   // 本地相册
    GalleryBody(useLocal: false, mode: 'photo'),  // 云端相册
    GalleryBody(useLocal: true, mode: 'file'),    // 本地文件
    GalleryBody(useLocal: false, mode: 'file'),   // 云端文件
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PHO'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: '本地相册',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: '云端相册',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: '本地文件',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud_queue),
            label: '云端文件',
          ),
        ],
      ),
    );
  }
}
