import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts(); // Ambil data dari API saat halaman pertama kali dibuka
  }

  // --- READ (AMBIL DATA DARI API) ---
  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Contoh Endpoint GET (Menggunakan FakeStoreAPI publik untuk latihan)
      final url = Uri.parse('https://fakestoreapi.com/products?limit=5');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _products = data.map((item) {
            return {
              'name': item['title'].toString(),
              'price': 'Rp ${(item['price'] * 15000).toStringAsFixed(0)}', // Konversi ke Rupiah tiruan
              'discount': '10%',
              'rating': item['rating'] != null ? item['rating']['rate'].toString() : '4.8',
              'sold': '100+ terjual',
              'location': 'Kota Jakarta',
              'image': item['image'].toString(),
              'stock': '50 stok',
            };
          }).toList();
        });
      } else {
        _showTokopediaSnackbar('Gagal memuat data dari server.');
      }
    } catch (e) {
      _showTokopediaSnackbar('Terjadi kesalahan koneksi: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- CREATE (TAMBAH PRODUK KE API) ---
  Future<void> _addProductToApi(Map<String, dynamic> newProduct) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('https://fakestoreapi.com/products');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': newProduct['name'],
          'price': 100.0,
          'description': 'Produk Tokopedia Himitsu',
          'image': 'https://picsum.photos/200',
          'category': 'electronic'
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _products.insert(0, newProduct); // Tambah ke urutan paling atas
        });
        _showTokopediaSnackbar('Produk berhasil ditambahkan!');
      } else {
        _showTokopediaSnackbar('Gagal menyimpan ke server.');
      }
    } catch (e) {
      _showTokopediaSnackbar('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- UPDATE (UBAH PRODUK) ---
  void _updateProduct(int index, Map<String, dynamic> updatedProduct) {
    setState(() {
      _products[index] = updatedProduct;
    });
    _showTokopediaSnackbar('Perubahan produk berhasil disimpan!');
  }

  // --- DELETE (HAPUS PRODUK) ---
  void _deleteProduct(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk?'),
        content: const Text('Produk yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                _products.removeAt(index);
              });
              Navigator.pop(context);
              _showTokopediaSnackbar('Produk berhasil dihapus.');
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showTokopediaSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF003D1B),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- FORM DIALOG (CREATE & UPDATE) ---
  void _showProductForm({int? index, Map<String, dynamic>? product}) {
    final nameController = TextEditingController(text: product?['name'] ?? '');
    final priceController = TextEditingController(text: product?['price'] ?? '');
    final stockController = TextEditingController(text: product?['stock'] ?? '10 stok');
    final locationController = TextEditingController(text: product?['location'] ?? 'Kota Bandung');
    final discountController = TextEditingController(text: product?['discount'] ?? '10%');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  index == null ? 'Tambah Produk Baru' : 'Edit Produk',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const Divider(),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Produk', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Harga (Contoh: Rp 75.000)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: stockController,
                      decoration: const InputDecoration(labelText: 'Stok', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: discountController,
                      decoration: const InputDecoration(labelText: 'Diskon', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Lokasi Toko', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00AA5B),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    if (nameController.text.isEmpty || priceController.text.isEmpty) return;

                    final newProductData = {
                      'name': nameController.text,
                      'price': priceController.text,
                      'discount': discountController.text,
                      'rating': product?['rating'] ?? '4.8',
                      'sold': product?['sold'] ?? '0 terjual',
                      'location': locationController.text,
                      'image': 'https://picsum.photos/200',
                      'stock': stockController.text,
                    };

                    Navigator.pop(context);

                    if (index == null) {
                      _addProductToApi(newProductData);
                    } else {
                      _updateProduct(index, newProductData);
                    }
                  },
                  child: Text(
                    index == null ? 'Simpan & Publikasikan' : 'Simpan Perubahan',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Tokopedia Seller (API Connected)',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        backgroundColor: const Color(0xFF00AA5B),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
            onPressed: _fetchProducts,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        color: Colors.white,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00AA5B),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: _isLoading ? null : () => _showProductForm(),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Tambah Produk Baru',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFE8F5E9),
            child: Row(
              children: [
                const Icon(Icons.storefront_rounded, color: Color(0xFF00AA5B), size: 18),
                const SizedBox(width: 8),
                Text(
                  'Kelola Toko: ${_products.length} Produk Terdaftar',
                  style: TextStyle(
                    color: Colors.green.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading && _products.isEmpty
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00AA5B)))
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _products.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.52,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      return ProductCard(
                        product: _products[index],
                        onEdit: () => _showProductForm(index: index, product: _products[index]),
                        onDelete: () => _deleteProduct(index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    child: Image.network(
                      product['image']!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Icon(Icons.broken_image_rounded, size: 40, color: Colors.grey));
                      },
                    ),
                  ),
                ),
                if (product['discount'] != null && product['discount'].toString().isNotEmpty)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFECEF),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                      ),
                      child: Text(
                        product['discount']!,
                        style: const TextStyle(color: Color(0xFFFF3A44), fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name']!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF212121), height: 1.3),
                ),
                const SizedBox(height: 4),
                Text(
                  product['price']!,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF212121), fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stok: ${product['stock'] ?? '-'}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          side: const BorderSide(color: Color(0xFF00AA5B)),
                          minimumSize: const Size(0, 28),
                        ),
                        onPressed: onEdit,
                        child: const Text('Edit', style: TextStyle(fontSize: 11, color: Color(0xFF00AA5B))),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}