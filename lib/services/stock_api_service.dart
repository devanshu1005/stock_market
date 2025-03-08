import 'dart:convert';
import 'package:http/http.dart' as http;

class StockApiService {
  static const String apiKey = 'JEA4DZIJGNCLAPZC';
  static const String baseUrl = 'https://www.alphavantage.co/query';

  // Function to search stocks by name
  Future<List<Map<String, String>>> searchStockByName(String query) async {
    final url = Uri.parse(
        '$baseUrl?function=SYMBOL_SEARCH&keywords=$query&apikey=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data.containsKey('Information')) {
        return [
          {
            'symbol': 'N/A',
            'name':
                'You have reached your daily search limit of 25 requests per day. Please try again tomorrow.'
          }
        ];
      }

      if (data['bestMatches'] != null) {
        return (data['bestMatches'] as List)
            .map((stock) => {
                  'symbol': stock['1. symbol'].toString(),
                  'name': stock['2. name'].toString(),
                })
            .toList();
      }
    }
    return [];
  }

  // Function to fetch stock details by symbol
  Future<Map<String, dynamic>> fetchStockData(String symbol) async {
    final url = Uri.parse(
        '$baseUrl?function=GLOBAL_QUOTE&symbol=$symbol&apikey=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load stock data');
    }
  }

  Future<List<Map<String, String>>> getTrendingStocks() async {
  return [
    {'symbol': 'AAPL', 'name': 'Apple Inc.'},
    {'symbol': 'TSLA', 'name': 'Tesla Inc.'},
    {'symbol': 'GOOGL', 'name': 'Alphabet Inc.'},
    {'symbol': 'AMZN', 'name': 'Amazon.com Inc.'},
    {'symbol': 'MSFT', 'name': 'Microsoft Corporation'},
    {'symbol': 'NVDA', 'name': 'NVIDIA Corporation'},
    {'symbol': 'META', 'name': 'Meta Platforms Inc.'},
    {'symbol': 'NFLX', 'name': 'Netflix Inc.'},
    {'symbol': 'BRK.A', 'name': 'Berkshire Hathaway Inc.'},
    {'symbol': 'V', 'name': 'Visa Inc.'},
  ];
}
}
