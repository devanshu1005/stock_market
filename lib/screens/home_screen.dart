// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'login_screen.dart';

// class HomeScreen extends StatelessWidget {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   void _logout(BuildContext context) async {
//     await _auth.signOut();
//     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Home Screen"),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.logout),
//             onPressed: () => _logout(context),
//           )
//         ],
//       ),
//       body: Center(
//         child: Text("Welcome to the Home Screen!", style: TextStyle(fontSize: 20)),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:stock_market/services/stock_api_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _stockService = StockApiService();
  final _searchController = TextEditingController();
  List<Map<String, String>> searchResults = [];
  Map<String, dynamic>? selectedStock;

  Future<void> searchStocks(String query) async {
    if (query.isNotEmpty) {
      final results = await _stockService.searchStockByName(query);
      setState(() {
        searchResults = results;
      });
    } else {
      setState(() {
        searchResults = [];
      });
    }
  }

  Future<void> fetchStockDetails(String symbol) async {
    final stock = await _stockService.fetchStockData(symbol);
    setState(() {
      selectedStock = stock;
      searchResults = [];
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stock Market Search')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search stocks by name...',
                border: OutlineInputBorder(),
              ),
              onChanged: searchStocks,
            ),
          ),
          Expanded(
            child: searchResults.isNotEmpty
                ? ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final stock = searchResults[index];
                      return ListTile(
                        title: Text(stock['name']!),
                        subtitle: Text(stock['symbol']!),
                        onTap: () => fetchStockDetails(stock['symbol']!),
                      );
                    },
                  )
                : selectedStock != null
                    ? Column(
                        children: [
                          Text('Symbol: ${selectedStock!['Global Quote']['01. symbol']}'),
                          Text('Price: \$${selectedStock!['Global Quote']['05. price']}'),
                        ],
                      )
                    : Center(child: Text('Search for a stock to get started')),
          ),
        ],
      ),
    );
  }
}

