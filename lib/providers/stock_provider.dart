import 'package:flutter/material.dart';
import 'package:stock_market/services/stock_api_service.dart';

class StockProvider with ChangeNotifier {
  final StockApiService _stockService = StockApiService();
  List<Map<String, String>> _searchResults = [];
  List<Map<String, String>> _trendingStocks = [];
  Map<String, dynamic> _stockDetails = {};

  List<Map<String, String>> get searchResults => _searchResults;
  List<Map<String, String>> get trendingStocks => _trendingStocks;
  Map<String, dynamic> get stockDetails => _stockDetails;

  Future<void> fetchTrendingStocks() async {
    _trendingStocks = await _stockService.getTrendingStocks();
    _searchResults = _trendingStocks;
    notifyListeners();
  }

  Future<void> searchStocks(String query) async {
    if (query.isNotEmpty) {
      _searchResults = await _stockService.searchStockByName(query);
    } else {
      _searchResults = _trendingStocks;
    }
    notifyListeners();
  }

  Future<void> fetchStockDetails(String symbol) async {
    _stockDetails = await _stockService.fetchStockData(symbol);
    notifyListeners();
  }

  Stream<Map<String, dynamic>> getRealTimeStockUpdates(String symbol) {
    return _stockService.getRealTimeStockUpdates(symbol);
  }
}