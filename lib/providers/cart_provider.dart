import 'package:flutter/material.dart';

// --- MODEL DATA UNTUK ITEM DI KERANJANG ---
class CartItem {
  final String id; // Tambahkan ID unik untuk keranjang (gabungan menuId + catatan)
  final int menuId;
  final String name;
  final int price;
  int quantity;
  final String imageUrl;
  final String? catatan; 

  CartItem({
    required this.id, // Wajib ada untuk key Map
    required this.menuId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    this.catatan, 
  });
}

// --- LOGIKA PROVIDER KERANJANG ---
class CartProvider with ChangeNotifier {
  // Ubah tipe Map dari <int, CartItem> menjadi <String, CartItem>
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  int get itemCount => _items.length;

  int get totalAmount {
    var total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  // Fungsi menambah item ke keranjang
  void addItem(
    int menuId,
    String name,
    int price,
    String imageUrl,
    int quantity, {
    String? catatan, // Parameter opsional
  }) {
    // 1. Buat key unik (Contoh: "5_Less sugar" atau "5_")
    String cartKey = '${menuId}_${catatan ?? ""}';

    if (_items.containsKey(cartKey)) {
      // Jika kopi dengan CATATAN YANG SAMA sudah ada, tambah jumlahnya
      _items.update(
        cartKey,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          menuId: existingCartItem.menuId,
          name: existingCartItem.name,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity + quantity,
          imageUrl: existingCartItem.imageUrl,
          catatan: existingCartItem.catatan,
        ),
      );
    } else {
      // Jika belum ada / catatannya berbeda, buat baris baru di keranjang
      _items.putIfAbsent(
        cartKey,
        () => CartItem(
          id: cartKey,
          menuId: menuId,
          name: name,
          price: price,
          quantity: quantity,
          imageUrl: imageUrl,
          catatan: catatan,
        ),
      );
    }
    notifyListeners();
  }

  // Fungsi untuk mengurangi jumlah item (Sekarang menggunakan cartKey berjenis String)
  void reduceQuantity(String cartKey) {
    if (!_items.containsKey(cartKey)) return;

    if (_items[cartKey]!.quantity > 1) {
      _items.update(
        cartKey,
        (existing) => CartItem(
          id: existing.id,
          menuId: existing.menuId,
          name: existing.name,
          price: existing.price,
          quantity: existing.quantity - 1,
          imageUrl: existing.imageUrl,
          catatan: existing.catatan,
        ),
      );
    } else {
      _items.remove(cartKey);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}