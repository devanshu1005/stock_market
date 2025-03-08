import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stock_market/screens/login_screen.dart';
import 'package:stock_market/screens/profile_screen.dart';
import 'package:stock_market/screens/stock_details_screen.dart';
import 'package:stock_market/services/stock_api_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _stockService = StockApiService();
  final _searchController = TextEditingController();
  List<Map<String, String>> searchResults = [];
  List<Map<String, String>> trendingStocks = [];

  @override
  void initState() {
    super.initState();
    _fetchTrendingStocks();
  }

  Future<void> _fetchTrendingStocks() async {
    final results =
        await _stockService.getTrendingStocks(); // Fetch trending stocks
    setState(() {
      trendingStocks = results;
      searchResults = results; // Initially display trending stocks
    });
  }

  Future<void> searchStocks(String query) async {
    if (query.isNotEmpty) {
      final results = await _stockService.searchStockByName(query);
      setState(() {
        searchResults = results;
      });
    } else {
      setState(() {
        searchResults =
            trendingStocks; // Restore trending stocks when search is empty
      });
    }
  }

  Future<void> fetchStockDetails(String symbol) async {
    final stock = await _stockService.fetchStockData(symbol);
    if (stock != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StockDetailScreen(stock: stock),
        ),
      );
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          height: 150,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.person),
                title: Text("Profile"),
                onTap: () {
                  Navigator.pop(context); // Close the sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text("Logout"),
                onTap: () => _logout(context),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stock Market Search"),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              _showBottomSheet(context);
            },
          ),
        ],
      ),
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

                      if (stock['symbol'] == 'N/A') {
                        return ListTile(
                          title: Text(stock['name']!,
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                        );
                      }

                      return ListTile(
                        title: Text(stock['name']!),
                        subtitle: Text(stock['symbol']!),
                        onTap: () => fetchStockDetails(stock['symbol']!),
                      );
                    },
                  )
                : Center(child: Text('Loading trending stocks...')),
          ),
        ],
      ),
    );
  }
}
