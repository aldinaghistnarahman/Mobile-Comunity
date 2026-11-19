import 'dart:convert';
import 'package:http/http.dart' as http;
// Tambahkan fungsi main ini di file lib/text.dart Anda

Future<void> main() async {
  final response = await http.get (
    Uri.parse('https://dummyjson.com/products'),
  );

  final data = jsonDecode(response.body);
  final products = data['products'];

  print(products[0]['title']);

  for (var product in products) {
    print(product ['title']);
  }
}