import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_market/providers/stock_provider.dart';
import 'package:intl/intl.dart';

class StockDetailScreen extends StatefulWidget {
  final String stockSymbol;

  StockDetailScreen({required this.stockSymbol});

  @override
  _StockDetailScreenState createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> with SingleTickerProviderStateMixin {
  late StreamSubscription<Map<String, dynamic>>? _stockStream;
  Map<String, dynamic>? _stockData;
  double? lastPrice;
  double? currentPrice;
  bool? isPriceUp;
  late TabController _tabController;
  final currencyFormat = NumberFormat.currency(symbol: '₹');
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final stockProvider = Provider.of<StockProvider>(context, listen: false);

    // Fetch initial stock details
    stockProvider.fetchStockDetails(widget.stockSymbol).then((_) {
      setState(() {
        _isLoading = false;
        final data = stockProvider.stockDetails;
        if (data.isNotEmpty && data['Global Quote'] != null) {
          lastPrice = double.tryParse(data['Global Quote']['05. price'] ?? "0");
        } else {
          _hasError = true;
          _errorMessage = 'API limit exceeded. Please try again later.';
        }
      });
    }).catchError((error) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load stock details. API limit may have been exceeded.';
      });
    });

    // Listen to real-time stock updates only if we have valid data
    try {
      _stockStream = stockProvider.getRealTimeStockUpdates(widget.stockSymbol).listen((data) {
        setState(() {
          if (data.isNotEmpty && data['Global Quote'] != null) {
            _stockData = data;
            currentPrice = double.tryParse(data['Global Quote']['05. price'] ?? "0");
            
            if (lastPrice != null && currentPrice != null) {
              isPriceUp = currentPrice! > lastPrice!;
              lastPrice = currentPrice;
            } else {
              lastPrice = currentPrice;
            }
          }
        });
      }, onError: (error) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Error in real-time updates. API limit may have been exceeded.';
        });
      });
    } catch (e) {
      // Handle any exception during stream setup
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to set up stock updates. API limit may have been exceeded.';
      });
    }
  }

  @override
  void dispose() {
    _stockStream?.cancel(); // Cancel the stream when the screen is disposed
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stockProvider = Provider.of<StockProvider>(context);
    final stockDetails = stockProvider.stockDetails;

    // Handle API limit exceeded case
    if (_hasError) {
      return _buildErrorScreen();
    }

    // Extract values from stock details - with null safety
    final symbol = stockDetails.isNotEmpty && stockDetails['Global Quote'] != null
        ? stockDetails['Global Quote']['01. symbol'] ?? widget.stockSymbol
        : widget.stockSymbol;
        
    final price = stockDetails.isNotEmpty && stockDetails['Global Quote'] != null
        ? double.tryParse(stockDetails['Global Quote']['05. price'] ?? "0") ?? 0.0
        : 0.0;
        
    final change = stockDetails.isNotEmpty && stockDetails['Global Quote'] != null
        ? double.tryParse(stockDetails['Global Quote']['09. change'] ?? "0") ?? 0.0
        : 0.0;
        
    final changePercent = stockDetails.isNotEmpty && stockDetails['Global Quote'] != null
        ? stockDetails['Global Quote']['10. change percent'] ?? "0%"
        : "0%";
        
    final volume = stockDetails.isNotEmpty && stockDetails['Global Quote'] != null
        ? int.tryParse(stockDetails['Global Quote']['06. volume'] ?? "0") ?? 0
        : 0;
        
    final prevClose = stockDetails.isNotEmpty && stockDetails['Global Quote'] != null
        ? double.tryParse(stockDetails['Global Quote']['08. previous close'] ?? "0") ?? 0.0
        : 0.0;
        
    final highDay = stockDetails.isNotEmpty && stockDetails['Global Quote'] != null
        ? double.tryParse(stockDetails['Global Quote']['03. high'] ?? "0") ?? 0.0
        : 0.0;
        
    final lowDay = stockDetails.isNotEmpty && stockDetails['Global Quote'] != null
        ? double.tryParse(stockDetails['Global Quote']['04. low'] ?? "0") ?? 0.0
        : 0.0;
        
    final latestDay = stockDetails.isNotEmpty && stockDetails['Global Quote'] != null
        ? stockDetails['Global Quote']['07. latest trading day'] ?? "-"
        : "-";

    final isPositive = change >= 0;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient (matching user details screen)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.8),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.6),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Custom app bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        "Stock Details",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.star_border,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Stock Overview Section
                if (_isLoading)
                  Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Column(
                      children: [
                        // Stock Title Section
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        symbol.length > 2 ? symbol.substring(0, 2) : symbol,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        symbol,
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Last updated: $latestDay",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              
                              SizedBox(height: 24),
                              
                              // Price Display
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    currencyFormat.format(currentPrice ?? price),
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Row(
                                    children: [
                                      Icon(
                                        isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                                        color: isPositive ? Colors.green.shade300 : Colors.red.shade300,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "${change.toStringAsFixed(2)} (${changePercent.replaceAll('%', '')}%)",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: isPositive ? Colors.green.shade300 : Colors.red.shade300,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              
                              if (isPriceUp != null)
                                Container(
                                  margin: EdgeInsets.only(top: 8),
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isPriceUp! ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isPriceUp! ? Icons.trending_up : Icons.trending_down,
                                        color: isPriceUp! ? Colors.green : Colors.red,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "Live Update",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: isPriceUp! ? Colors.green : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        
                        // Main Content
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  spreadRadius: 1,
                                  blurRadius: 10,
                                  offset: Offset(0, -5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Tab Bar
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: TabBar(
                                      controller: _tabController,
                                      indicator: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      labelColor: Colors.white,
                                      unselectedLabelColor: Colors.grey.shade700,
                                      labelStyle: TextStyle(fontWeight: FontWeight.w600),
                                      tabs: [
                                        Tab(text: "Overview"),
                                        Tab(text: "Stats"),
                                        Tab(text: "News"),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                // Tab Content
                                Expanded(
                                  child: TabBarView(
                                    controller: _tabController,
                                    children: [
                                      // Overview Tab
                                      _buildOverviewTab(highDay, lowDay, prevClose, volume),
                                      
                                      // Stats Tab
                                      _buildStatsTab(price, prevClose, volume, change, changePercent),
                                      
                                      // News Tab
                                      _buildNewsTab(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          // Price Change Animation (conditional)
          if (isPriceUp != null)
            Positioned(
              top: 180,
              right: 20,
              child: _buildPriceChangeIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.8),
              Theme.of(context).colorScheme.secondary.withOpacity(0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom app bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      "Stock Details",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: Center(
                  child: Container(
                    margin: EdgeInsets.all(24),
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "API Limit Exceeded",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Go Back"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceChangeIndicator() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isPriceUp! ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
      ),
      child: Center(
        child: Icon(
          isPriceUp! ? Icons.arrow_upward : Icons.arrow_downward,
          color: isPriceUp! ? Colors.green : Colors.red,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildOverviewTab(double highDay, double lowDay, double prevClose, int volume) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Price Summary",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          
          // Price Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  "Day High",
                  currencyFormat.format(highDay),
                  Icons.arrow_upward,
                  Colors.green,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  "Day Low",
                  currencyFormat.format(lowDay),
                  Icons.arrow_downward,
                  Colors.red,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  "Previous Close",
                  currencyFormat.format(prevClose),
                  Icons.history,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  "Volume",
                  _formatVolume(volume),
                  Icons.bar_chart,
                  Colors.purple,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 32),
          Text(
            "Performance Chart",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          
          // Mock Chart
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                Icons.show_chart,
                size: 80,
                color: Colors.grey.shade400,
              ),
            ),
          ),
          
          SizedBox(height: 32),
          Text(
            "About",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "This section would typically show company overview, description, sector information, and other fundamental details about the stock.",
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab(double price, double prevClose, int volume, double change, String changePercent) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Key Statistics",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          
          _buildStatRow("Current Price", currencyFormat.format(price)),
          _buildStatRow("Previous Close", currencyFormat.format(prevClose)),
          _buildStatRow("Day Change", change.toStringAsFixed(2)),
          _buildStatRow("Change %", changePercent),
          _buildStatRow("Volume", _formatVolume(volume)),
          _buildStatRow("Market Cap", "₹ 2.4T"),
          _buildStatRow("P/E Ratio", "22.5"),
          _buildStatRow("Dividend Yield", "1.2%"),
          _buildStatRow("52-Week High", "₹ 1,899.00"),
          _buildStatRow("52-Week Low", "₹ 1,356.00"),
          _buildStatRow("Beta", "1.15"),
          _buildStatRow("EPS", "₹ 78.65"),
          
          SizedBox(height: 32),
          Text(
            "Technical Indicators",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          
          _buildStatRow("RSI (14)", "58.23"),
          _buildStatRow("MACD", "5.67"),
          _buildStatRow("20-Day MA", currencyFormat.format(price - 15)),
          _buildStatRow("50-Day MA", currencyFormat.format(price - 32)),
          _buildStatRow("200-Day MA", currencyFormat.format(price - 75)),
        ],
      ),
    );
  }

  Widget _buildNewsTab() {
    // Mock news data
    List<Map<String, dynamic>> newsItems = [
      {
        "title": "Q4 Results: Profits Exceed Expectations",
        "source": "Financial Times",
        "time": "2 hours ago",
        "imageUrl": "https://example.com/image1.jpg"
      },
      {
        "title": "New Product Launch Announced",
        "source": "Business Today",
        "time": "5 hours ago",
        "imageUrl": "https://example.com/image2.jpg"
      },
      {
        "title": "CEO Interview: Future Growth Plans",
        "source": "Economic Times",
        "time": "Yesterday",
        "imageUrl": "https://example.com/image3.jpg"
      },
      {
        "title": "Industry Analysis: Market Share Growing",
        "source": "Bloomberg",
        "time": "2 days ago",
        "imageUrl": "https://example.com/image4.jpg"
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: newsItems.length,
      itemBuilder: (context, index) {
        final news = newsItems[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 1,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.article,
                    size: 30,
                    color: Colors.grey.shade400,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        news["title"]!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            news["source"]!,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            height: 4,
                            width: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            news["time"]!,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatVolume(int volume) {
    if (volume >= 1000000000) {
      return "${(volume / 1000000000).toStringAsFixed(1)}B";
    } else if (volume >= 1000000) {
      return "${(volume / 1000000).toStringAsFixed(1)}M";
    } else if (volume >= 1000) {
      return "${(volume / 1000).toStringAsFixed(1)}K";
    } else {
      return volume.toString();
    }
  }
}