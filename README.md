# Tugas 1 Pemrograman Aplikasi Bergerak

### Shafa Rizqi Nur Wahidah (2409116041)

## lib/main.dart

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/cart_model.dart';
import 'pages/product_list_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => CartModel(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shopping Cart',
      theme: ThemeData(useMaterial3: true),
      home: const ProductListPage(),
    );
```

File main.dart merupakan titik awal (entry point) dari aplikasi Flutter ini. Setiap aplikasi Flutter wajib memiliki file ini karena di sinilah proses menjalankan aplikasi dimulai.

Pada file ini, fungsi main() digunakan untuk menjalankan aplikasi menggunakan runApp(). Aplikasi dibungkus dengan ChangeNotifierProvider dari package provider, yang berfungsi sebagai state management. Provider ini digunakan untuk mengelola data keranjang belanja (CartModel) agar bisa diakses dan diperbarui oleh seluruh halaman dalam aplikasi.

Class MyApp berperan sebagai widget utama aplikasi. Di dalamnya terdapat konfigurasi dasar seperti judul aplikasi, pengaturan tema, serta halaman awal (home) yang diarahkan ke ProductListPage. Dengan struktur ini, aplikasi sudah siap menggunakan state global untuk fitur shopping cart.

## lib/models/product.dart

```dart
class Product {
  final String id;
  final String name;
  final double price;
  final String emoji;
  final String description;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.emoji,
    required this.description,
    required this.category,
  });
}
```

File product.dart berisi model data Product yang merepresentasikan barang atau produk yang dijual dalam aplikasi.

Class Product memiliki beberapa properti penting seperti id, name, price, emoji, description, dan category. Properti category digunakan untuk mendukung fitur filter berdasarkan kategori, sedangkan emoji digunakan sebagai representasi visual produk tanpa perlu gambar eksternal.

Model ini berfungsi sebagai blueprint data produk, sehingga setiap produk yang ditampilkan di halaman product list memiliki struktur data yang konsisten dan mudah dikelola.

## lib/models/cart_item.dart

```dart
import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;
}
```

File cart_item.dart digunakan untuk merepresentasikan item yang ada di dalam keranjang belanja.

Class CartItem menyimpan satu produk (Product) beserta jumlahnya (quantity). File ini juga memiliki properti totalPrice yang merupakan calculated property, yaitu hasil perkalian antara harga produk dan jumlahnya. Dengan adanya properti ini, perhitungan subtotal setiap item menjadi lebih rapi dan tidak perlu ditulis berulang di UI.

File ini membantu memisahkan logika data keranjang dari tampilan, sehingga kode menjadi lebih terstruktur.

## lib/models/cart_model.dart

```dart
import 'package:flutter/foundation.dart';
import 'cart_item.dart';
import 'product.dart';

class CartModel extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get itemsList => _items.values.toList();
  bool get isEmpty => _items.isEmpty;

  int get totalQuantity =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity++;
    } else {
      _items[product.id] = CartItem(product: product);
    }
    notifyListeners();
  }

  void increaseQuantity(String id) {
    _items[id]!.quantity++;
    notifyListeners();
  }

  void decreaseQuantity(String id) {
    if (_items[id]!.quantity > 1) {
      _items[id]!.quantity--;
    } else {
      _items.remove(id);
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
```

File cart_model.dart merupakan inti dari sistem shopping cart pada aplikasi ini. Class CartModel menggunakan ChangeNotifier agar setiap perubahan data bisa langsung memperbarui tampilan UI.

Data keranjang disimpan dalam bentuk Map<String, CartItem> dengan id produk sebagai key, sehingga pencarian dan update item menjadi lebih efisien. File ini menyediakan berbagai method seperti:

1. addItem() untuk menambahkan produk ke keranjang

2. increaseQuantity() dan decreaseQuantity() untuk mengubah jumlah produk

3. removeItem() untuk menghapus produk tertentu

4. clear() untuk mengosongkan seluruh keranjang

Selain itu, terdapat getter seperti totalQuantity dan totalPrice yang digunakan untuk menghitung total item dan total harga secara otomatis. File ini memastikan seluruh logika bisnis keranjang terpusat di satu tempat.

## lib/pages/product_list_page.dart

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/cart_model.dart';
import 'cart_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  String searchQuery = '';
  String selectedCategory = 'All';

  final products = [
    Product(
      id: '1',
      name: 'Laptop Gaming',
      price: 15000000,
      emoji: '💻',
      description: 'Laptop performa tinggi',
      category: 'Electronics',
    ),
    Product(
      id: '2',
      name: 'Smartphone Pro',
      price: 8000000,
      emoji: '📱',
      description: 'Flagship phone',
      category: 'Electronics',
    ),
    Product(
      id: '3',
      name: 'Headphones',
      price: 1500000,
      emoji: '🎧',
      description: 'Noise cancelling',
      category: 'Accessories',
    ),
    Product(
      id: '4',
      name: 'Smart Watch',
      price: 3000000,
      emoji: '⌚',
      description: 'Health tracking',
      category: 'Accessories',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredProducts = products.where((p) {
      final searchMatch = p.name.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      final categoryMatch =
          selectedCategory == 'All' || p.category == selectedCategory;
      return searchMatch && categoryMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search product...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => searchQuery = v),
            ),
          ),
          DropdownButton<String>(
            value: selectedCategory,
            items: [
              'All',
              'Electronics',
              'Accessories',
            ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => selectedCategory = v!),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (_, i) {
                final product = filteredProducts[i];
                return Card(
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            product.emoji,
                            style: const TextStyle(fontSize: 50),
                          ),
                        ),
                      ),
                      Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Rp ${product.price.toStringAsFixed(0)}'),
                      ElevatedButton(
                        onPressed: () {
                          context.read<CartModel>().addItem(product);
                        },
                        child: const Text('Add to Cart'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

File product_list_page.dart berfungsi sebagai halaman utama aplikasi yang menampilkan daftar produk.

Pada halaman ini terdapat:

1. Search bar untuk mencari produk berdasarkan nama

2. Dropdown kategori untuk memfilter produk berdasarkan kategori

3. GridView untuk menampilkan produk dalam bentuk grid

4. Tombol Add to Cart yang terhubung langsung ke CartModel menggunakan Provider

Data produk difilter secara real-time berdasarkan input search dan kategori yang dipilih. Halaman ini juga memiliki ikon keranjang di AppBar yang mengarahkan pengguna ke halaman Cart. File ini menggabungkan UI dan interaksi utama pengguna dengan produk.

## lib/pages/cart_page.dart

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: cart.isEmpty
          ? const Center(child: Text('Cart kosong'))
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    children: cart.itemsList.map((item) {
                      return ListTile(
                        leading: Text(
                          item.product.emoji,
                          style: const TextStyle(fontSize: 30),
                        ),
                        title: Text(item.product.name),
                        subtitle: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () =>
                                  cart.decreaseQuantity(item.product.id),
                            ),
                            Text('${item.quantity}'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () =>
                                  cart.increaseQuantity(item.product.id),
                            ),
                          ],
                        ),
                        trailing: Text(
                          'Rp ${item.totalPrice.toStringAsFixed(0)}',
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Total: Rp ${cart.totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CheckoutPage(),
                            ),
                          );
                        },
                        child: const Text('Checkout'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
```

File cart_page.dart digunakan untuk menampilkan isi keranjang belanja.

Halaman ini menampilkan daftar produk yang telah ditambahkan ke keranjang lengkap dengan Nama produk, Emoji produk, Quantity (+ / -), dan Subtotal harga per item.

Pengguna dapat menambah atau mengurangi jumlah produk langsung dari halaman ini. Di bagian bawah halaman, ditampilkan total harga keseluruhan serta tombol Checkout untuk melanjutkan ke halaman checkout. Jika keranjang kosong, aplikasi akan menampilkan pesan bahwa cart masih kosong.

## lib/pages/checkout_page.dart

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...cart.itemsList.map(
              (e) => Text(
                '${e.product.name} x${e.quantity} = Rp ${e.totalPrice.toStringAsFixed(0)}',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: addressCtrl,
              decoration: const InputDecoration(labelText: 'Alamat'),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  cart.clear();
                  Navigator.popUntil(context, (r) => r.isFirst);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Order berhasil')),
                  );
                },
                child: const Text('Confirm Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

File checkout_page.dart merupakan halaman checkout yang berfungsi sebagai tahap akhir sebelum pemesanan selesai.

Pada halaman ini ditampilkan:

1. Order summary, yaitu daftar produk beserta jumlah dan total harganya

2. Form input sederhana berupa nama dan alamat

3. Tombol Confirm Order untuk menyelesaikan transaksi

Saat tombol konfirmasi ditekan, data keranjang akan dikosongkan menggunakan method clear() dari CartModel, lalu pengguna diarahkan kembali ke halaman utama. Halaman ini melengkapi alur aplikasi dari product list → cart → checkout secara utuh.

## Dokumentasi Program

Tampilan Awal

<img width="527" height="1121" alt="image" src="https://github.com/user-attachments/assets/cb6aae3a-cc7f-4a9b-970f-f806021b92a7" />

Fitur Sortir

<img width="535" height="1126" alt="image" src="https://github.com/user-attachments/assets/42a3fa31-d9b3-46bb-ae6e-2990fd392459" />

<img width="525" height="1129" alt="image" src="https://github.com/user-attachments/assets/3735b551-fe21-41ab-ae58-106f7eb87dc6" />

Checkout

<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/93e1f607-8cf6-49f7-ad00-4c8596c566a3" />

<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/c127fa9e-ab82-4de7-a186-6ff23ad9b9e4" />
