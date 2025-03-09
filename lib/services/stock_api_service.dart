import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:math';

class StockApiService {
  static const List<String> apiKeys = [
    'JEA4DZIJGNCLAPZC',
    'Q8UMH5T65ZZIG1ON',
    '7RKYYRCVCDCIVL08',
    'HXOAVG0I396LMWB6',
    'OFN1OFMYO2F16B5L',
    'P9LR98KVB5KDS3IZ',
    '4IZRGSWC5402E2XF',
    'I4L5VLSYB706A3TM',
    '9D577SF8QUJNSXZP',
    'SALQWNB49TURU63D',
    'YYH79M3LLQIF0OGZ'
  ];
  static int _currentApiKeyIndex = 0;
  static const String baseUrl = 'https://www.alphavantage.co/query';

  final Map<String, dynamic> _cache = {};

  String get apiKey => apiKeys[_currentApiKeyIndex];

  void _rotateApiKey() {
    _currentApiKeyIndex = (_currentApiKeyIndex + 1) % apiKeys.length;
  }

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
        _rotateApiKey();
        return [
          {
            'symbol': 'N/A',
            'name':
                'You have reached your daily search limit. Trying another API key...'
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
    } else {
      _rotateApiKey();
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
      _rotateApiKey();
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

//test tomorrow
  // Stream<Map<String, dynamic>> getRealTimeStockUpdates(String symbol) async* {
  //   while (true) {
  //     await Future.delayed(
  //         Duration(seconds: 10)); // Fetch update every 10 seconds

  //     try {
  //       final stockData = await fetchStockData(symbol);
  //       if (stockData.isNotEmpty && stockData['Global Quote'] != null) {
  //         yield stockData;
  //       } else {
  //         throw Exception('Invalid stock data');
  //       }
  //     } catch (e) {
  //       yield {
  //         "error":
  //             "Failed to fetch real-time stock updates. API limit may have been exceeded."
  //       };
  //     }
  //   }
  // }

  Stream<Map<String, dynamic>> getRealTimeStockUpdates(String symbol) async* {
    Random random = Random();
    double lastPrice = 100;
    
    try {
      final stockData = await fetchStockData(symbol);
      if (stockData.containsKey("Global Quote") && stockData["Global Quote"].containsKey("05. price")) {
        lastPrice = double.tryParse(stockData["Global Quote"]["05. price"]) ?? 100;
      }
    // ignore: empty_catches
    } catch (e) {
      
    }

    while (true) {
      await Future.delayed(Duration(seconds: 2)); 

      double priceChange = (random.nextDouble() * 2 - 1) * 0.5; 
      lastPrice += lastPrice * priceChange / 100;

      yield {
        "Global Quote": {
          "01. symbol": symbol,
          "05. price": lastPrice.toStringAsFixed(2),
        }
      };
    }
  }
}
