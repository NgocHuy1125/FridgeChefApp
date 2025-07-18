import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _controller = TextEditingController();
  List _meals = [];
  bool _loading = false;

  Future<void> _searchMeals() async {
    setState(() => _loading = true);
    final ingredients = _controller.text.trim();

    final response = await http.get(
      Uri.parse(
        'https://www.themealdb.com/api/json/v1/1/filter.php?i=$ingredients',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _meals = data['meals'] ?? [];
        _loading = false;
      });
    } else {
      setState(() {
        _meals = [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tìm món theo nguyên liệu')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Nhập nguyên liệu (vd: chicken,tomato)',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchMeals,
                ),
              ),
              onSubmitted: (value) => _searchMeals(),
            ),
            SizedBox(height: 20),
            _loading
                ? CircularProgressIndicator()
                : Expanded(
                  child: ListView.builder(
                    itemCount: _meals.length,
                    itemBuilder: (context, index) {
                      final meal = _meals[index];
                      return ListTile(
                        leading: Image.network(meal['strMealThumb']),
                        title: Text(meal['strMeal']),
                        onTap: () {
                           // TODO: Điều hướng sang trang chi tiết món ăn
                          Navigator.pushNamed(
                            context,
                            '/detail',
                            arguments: meal['idMeal'],
                          );
                        },
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
