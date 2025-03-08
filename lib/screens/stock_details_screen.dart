import 'package:flutter/material.dart';

class StockDetailScreen extends StatelessWidget {
  final Map<String, dynamic> stock;

  StockDetailScreen({required this.stock});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stock Details')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Symbol: ${stock['Global Quote']['01. symbol']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Price: \Rs.${stock['Global Quote']['05. price']}', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
