import 'dart:convert';
import 'package:http/http.dart' as http;

class StockApiService {
  static const String apiKey = 'JEA4DZIJGNCLAPZC';
  static const String baseUrl = 'https://www.alphavantage.co/query';

  // Function to search stocks by name
  Future<List<Map<String, String>>> searchStockByName(String query) async {
  final url = Uri.parse('$baseUrl?function=SYMBOL_SEARCH&keywords=$query&apikey=$apiKey');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['bestMatches'] != null) {
      return (data['bestMatches'] as List)
          .map((stock) => {
                'symbol': stock['1. symbol'].toString(), // Explicitly convert to String
                'name': stock['2. name'].toString(), // Explicitly convert to String
              })
          .toList();
    }
  }
  return [];
}

  // Function to fetch stock details by symbol
  Future<Map<String, dynamic>> fetchStockData(String symbol) async {
    final url = Uri.parse('$baseUrl?function=GLOBAL_QUOTE&symbol=$symbol&apikey=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load stock data');
    }
  }
}
