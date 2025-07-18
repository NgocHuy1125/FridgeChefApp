import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy màu cam vàng từ theme chính của ứng dụng
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color secondaryColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent, // Đặt trong suốt để sử dụng flexibleSpace
        title: const Text(
          'Yêu thích', // Tiêu đề tiếng Việt
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu_book, color: Colors.white),
          onPressed: () {
            // Xử lý khi nhấn nút
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Xử lý khi nhấn nút ba chấm
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor, // Sử dụng màu cam từ theme chính
                secondaryColor.withOpacity(0.8), // Sử dụng màu vàng từ theme chính
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0, left: 16.0, right: 16.0),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      hintText: 'Tìm kiếm...', // Hint text tiếng Việt
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        toolbarHeight: kToolbarHeight + 60,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon hoặc ảnh minh họa
                // Vẫn dùng placeholder icon nếu không có ảnh cụ thể
                // Bạn có thể thay thế bằng Image.asset nếu có file ảnh cookbook_icon.png
                Image.asset(
                  'assets/images/cookbook_icon.png', // Thay thế bằng đường dẫn ảnh thật của bạn
                  height: 100,
                  width: 100,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.book_online,
                      size: 100,
                      color: Colors.grey[400],
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Chỉ người dùng đã đăng ký mới có thể lưu công thức', // Text tiếng Việt
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    print('Nút "Đăng ký miễn phí" đã được nhấn!');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Giữ nút màu xanh lá như ảnh gốc
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Đăng ký miễn phí', // Text nút tiếng Việt
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}