import 'package:flutter/material.dart';
import '../utils/storage_helper.dart';

class ProfileScreen extends StatelessWidget {
  Future<List<String>> _loadList(String key) async {
    return await StorageHelper.getStringList(key);
  }

  Widget _buildSection(String title, String key) {
    return FutureBuilder(
      future: _loadList(key),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final list = snapshot.data as List<String>;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              ...list.map((e) => Text('- $e')).toList(),
              SizedBox(height: 10),
            ],
          );
        }
        return CircularProgressIndicator();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hồ sơ")),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection("Món đã nấu", "cooked"),
              _buildSection("Món đã xem", "viewed"),
              _buildSection("Yêu thích", "favorites"),
              _buildSection("Nguyên liệu trong tủ", "pantry"),
            ],
          ),
        ),
      ),
    );
  }
}
  