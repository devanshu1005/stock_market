import 'package:flutter/material.dart';
import 'package:stock_market/services/stock_api_service.dart';
import 'dart:async';

class StockDetailScreen extends StatefulWidget {
  final String stockSymbol;

  StockDetailScreen({required this.stockSymbol, required Map<String, dynamic> stock});

  @override
  _StockDetailScreenState createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  final StockApiService _stockApiService = StockApiService();
  late StreamSubscription<Map<String, dynamic>> _stockStream;
  Map<String, dynamic>? _stockData;
  double? lastPrice;

  @override
  void initState() {
    super.initState();
    _stockStream = _stockApiService.getRealTimeStockUpdates(widget.stockSymbol).listen((data) {
      setState(() {
        _stockData = data;
        lastPrice = double.tryParse(data['Global Quote']['05. price'] ?? "0");
      });
    });
  }

  @override
  void dispose() {
    _stockStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stock Details')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: _stockData == null
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Symbol: ${_stockData!['Global Quote']['01. symbol']}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text('Price: \Rs.${_stockData!['Global Quote']['05. price']}',
                          style: TextStyle(fontSize: 18)),
                      SizedBox(width: 10),
                      if (lastPrice != null) _getPriceChangeIndicator(lastPrice!),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _getPriceChangeIndicator(double newPrice) {
    if (lastPrice == null) return SizedBox.shrink();

    return Icon(
      newPrice > lastPrice! ? Icons.arrow_upward : Icons.arrow_downward,
      color: newPrice > lastPrice! ? Colors.green : Colors.red,
    );
  }
}
