import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:math';

class StockApiService {
  // static const String apiKey = 'JEA4DZIJGNCLAPZC';
  // static const String apiKey = 'Q8UMH5T65ZZIG1ON';
  static const String apiKey = '7RKYYRCVCDCIVL08';
  static const String baseUrl = 'https://www.alphavantage.co/query';

  final Map<String, dynamic> _cache = {};

  Future<List<Map<String, String>>> searchStockByName(String query) async {
    if (_cache.containsKey('search_$query')) {
      return _cache['search_$query'];
    }

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
        final results = (data['bestMatches'] as List)
            .map((stock) => {
                  'symbol': stock['1. symbol'].toString(),
                  'name': stock['2. name'].toString(),
                })
            .toList();
        _cache['search_$query'] = results;
        return results;
      }
    }
    return [];
  }

  Future<Map<String, dynamic>> fetchStockData(String symbol) async {
    if (_cache.containsKey('stock_$symbol')) {
      return _cache['stock_$symbol'];
    }

    final url = Uri.parse(
        '$baseUrl?function=GLOBAL_QUOTE&symbol=$symbol&apikey=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _cache['stock_$symbol'] = data;
      return data;
    } else {
      throw Exception('Failed to load stock data');
    }
  }

  Future<List<Map<String, String>>> getTrendingStocks() async {
    if (_cache.containsKey('trending')) {
      return _cache['trending'];
    }

    final results = [
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

    _cache['trending'] = results;
    return results;
  }

  Stream<Map<String, dynamic>> getRealTimeStockUpdates(String symbol) async* {
    Random random = Random();
    double lastPrice = random.nextDouble() * 1000; // Initial random price

    while (true) {
      await Future.delayed(Duration(seconds: 2)); // Simulate updates every 2s

      double priceChange = (random.nextDouble() * 10 - 5); // Random change (-5 to +5)
      lastPrice += priceChange;

      yield {
        "Global Quote": {
          "01. symbol": symbol,
          "05. price": lastPrice.toStringAsFixed(2),
        }
      };
    }
  }
}