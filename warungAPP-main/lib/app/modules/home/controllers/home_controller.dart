import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/food_item.dart';

class HomeController extends GetxController {
  var selectedCategory = 'Nasi'.obs;
  var cartItems = 0.obs;
  var orderItems = <OrderItem>[].obs;
  var totalAmount = 0.0.obs;
  var discountAmount = 0.0.obs;

  final categories = [
    {'icon': '🍚', 'name': 'Nasi'},
    {'icon': '🍖', 'name': 'Ayam'},
    {'icon': '🐟', 'name': 'Ikan'},
    {'icon': '🥤', 'name': 'Minuman'},
    {'name': 'Daging', 'icon': '🍖'},
    {'name': 'Sayur', 'icon': '🍆'},
  ];

  final popularItems = [
    FoodItem(
      name: 'Nasi Pecel',
      image: 'assets/nasi_pecel.jpg',
      price: 25000.0,
      description: 'Dengan sayur dan bumbu pecel',
    ),
    FoodItem(
      name: 'Ayam Panggang',
      image: 'assets/ayam_panggang.jpg',
      price: 30000.0,
      description: 'Ayam panggang dengan bumbu special',
    ),
    FoodItem(
      name: 'Ikan Bakar',
      image: 'assets/ikan_bakar.jpg',
      price: 28000.0,
      description: 'Ikan bakar dengan sambal',
    ),
    FoodItem(
      name: 'Rawon',
      image: 'assets/rawon.jpg',
      price: 25000.0,
      description: 'Rawon daging sapi',
    ),
  ];

  void _showCustomSnackbar({
    required String title,
    required String message,
    Color backgroundColor = Colors.green,
    IconData icon = Icons.check_circle,
    SnackPosition position = SnackPosition.TOP,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      duration: Duration(seconds: 2),
      backgroundColor: backgroundColor.withOpacity(0.9),
      colorText: Colors.white,
      borderRadius: 10,
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      icon: Icon(
        icon,
        color: Colors.white,
        size: 28,
      ),
      shouldIconPulse: true,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  void addToCart(FoodItem item) {
    var existingItem = orderItems.firstWhere(
          (element) => element.foodItem.name == item.name,
      orElse: () => OrderItem(foodItem: item, quantity: 0),
    );

    if (existingItem.quantity == 0) {
      orderItems.add(OrderItem(foodItem: item, quantity: 1));
    } else {
      existingItem.quantity++;
      orderItems.refresh();
    }

    cartItems.value = orderItems.fold(0, (sum, item) => sum + item.quantity);
    _calculateTotalAmount();

    _showCustomSnackbar(
      title: 'Berhasil Ditambahkan',
      message: '${item.name} telah ditambahkan ke keranjang',
      icon: Icons.shopping_cart_checkout,
    );
  }

  void removeFromCart(OrderItem item) {
    if (item.quantity > 1) {
      item.quantity--;
      orderItems.refresh();
    } else {
      orderItems.remove(item);
    }

    cartItems.value = orderItems.fold(0, (sum, item) => sum + item.quantity);
    _calculateTotalAmount();

    _showCustomSnackbar(
      title: 'Item Dihapus',
      message: '${item.foodItem.name} telah dihapus dari keranjang',
      backgroundColor: Colors.orange,
      icon: Icons.remove_shopping_cart,
    );
  }

  void _calculateTotalAmount() {
    totalAmount.value = orderItems.fold(
      0.0,
          (sum, item) => sum + (item.foodItem.price * item.quantity),
    );
    discountAmount.value = totalAmount.value * 0.3;
  }

  void clearCart() {
    orderItems.clear();
    cartItems.value = 0;
    totalAmount.value = 0;
    discountAmount.value = 0;
  }

  Future<void> placeOrder() async {
    if (orderItems.isEmpty) {
      _showCustomSnackbar(
        title: 'Pesanan Gagal',
        message: 'Silakan tambahkan menu ke keranjang terlebih dahulu',
        backgroundColor: Colors.red,
        icon: Icons.error_outline,
      );
      return;
    }

    // Simulating API call
    await Future.delayed(Duration(seconds: 2));

    final orderNumber = DateTime.now().millisecondsSinceEpoch.toString().substring(7);

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Column(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 50,
            ),
            SizedBox(height: 10),
            Text(
              'Pesanan Berhasil!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderInfoRow(
                'Nomor Pesanan:',
                '#$orderNumber',
                Icons.receipt_long,
              ),
              SizedBox(height: 12),
              _buildOrderInfoRow(
                'Total Item:',
                '${cartItems.value}',
                Icons.shopping_basket,
              ),
              SizedBox(height: 12),
              _buildOrderInfoRow(
                'Total Bayar:',
                'Rp ${(totalAmount.value - discountAmount.value).toStringAsFixed(0)}',
                Icons.payments,
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                  'Terima kasih telah memesan!',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              clearCart();
              Get.until((route) => route.isFirst);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Selesai',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class OrderItem {
  final FoodItem foodItem;
  int quantity;

  OrderItem({
    required this.foodItem,
    required this.quantity,
  });
}

