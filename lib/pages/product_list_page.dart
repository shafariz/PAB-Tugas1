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
