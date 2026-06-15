import 'package:flutter/material.dart';

// --- MODEL DATA UNTUK ITEM DI KERANJANG ---
class CartItem {
  final int menuId;
  final String name;
  final int price;
  int quantity;
  final String imageUrl;

  CartItem({
    required this.menuId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });
}

// --- LOGIKA PROVIDER KERANJANG ---
class CartProvider with ChangeNotifier {
  // Menggunakan Map agar lebih mudah mencari menu berdasarkan ID
  final Map<int, CartItem> _items = {};

  Map<int, CartItem> get items => _items;

  // Menghitung jumlah unik jenis menu di keranjang (untuk angka di Badge merah)
  int get itemCount => _items.length;

  // Menghitung total harga semua pesanan
  int get totalAmount {
    var total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  // Fungsi menambah item ke keranjang
  void addItem(int menuId, String name, int price, String imageUrl, int quantity) {
    if (_items.containsKey(menuId)) {
      // Jika kopi sudah ada di keranjang, cukup tambahkan jumlahnya (quantity)
      _items.update(
        menuId,
        (existingCartItem) => CartItem(
          menuId: existingCartItem.menuId,
          name: existingCartItem.name,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity + quantity,
          imageUrl: existingCartItem.imageUrl,
        ),
      );
    } else {
      // Jika kopi belum ada, buat entri baru
      _items.putIfAbsent(
        menuId,
        () => CartItem(
          menuId: menuId,
          name: name,
          price: price,
          quantity: quantity,
          imageUrl: imageUrl,
        ),
      );
    }
    // Wajib dipanggil agar seluruh UI (seperti Badge merah) ter-update otomatis
    notifyListeners(); 
  }

  // Fungsi untuk mengurangi jumlah item atau menghapusnya jika sisa 1
  void reduceQuantity(int menuId) {
    if (!_items.containsKey(menuId)) return;

    if (_items[menuId]!.quantity > 1) {
      _items.update(
        menuId,
        (existing) => CartItem(
          menuId: existing.menuId,
          name: existing.name,
          price: existing.price,
          quantity: existing.quantity - 1,
          imageUrl: existing.imageUrl,
        ),
      );
    } else {
      _items.remove(menuId);
    }
    notifyListeners();
  }

  // Fungsi untuk membersihkan keranjang (dipanggil setelah sukses bayar)
  void clear() {
    _items.clear();
    notifyListeners();
  }
}