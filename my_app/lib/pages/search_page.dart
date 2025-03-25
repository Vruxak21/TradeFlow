// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class SearchPage extends StatefulWidget {
//   const SearchPage({super.key});

//   @override
//   State<SearchPage> createState() => _SearchPageState();
// }

// class _SearchPageState extends State<SearchPage> {
//   final TextEditingController _searchController = TextEditingController();
//   List<dynamic> _stockResults = [];
//   bool _isLoading = false;
//   bool _searchPerformed = false;
//   String _selectedExchange = 'NSE'; // Default to NSE

//   // Alpha Vantage API key
//   final String _apiKey = '28JYSHXPRR3XA13H'; // Replace with your key

//   // Popular Indian stocks with their symbols
//   final Map<String, List<String>> _popularStocks = {
//     'NSE': ['RELIANCE', 'TCS', 'HDFCBANK', 'INFY', 'HDFC'],
//     'BSE': ['RELIANCE.BO', 'TCS.BO', 'HDFCBANK.BO', 'INFY.BO', 'HDFC.BO'],
//   };

//   @override
//   void initState() {
//     super.initState();
//     _fetchTopStocks();
//   }

//   Future<void> _fetchTopStocks() async {
//     if (!mounted) return;

//     setState(() {
//       _isLoading = true;
//       _searchPerformed = false;
//     });

//     try {
//       List<dynamic> results = [];
//       final symbols = _popularStocks[_selectedExchange] ?? [];

//       for (String symbol in symbols) {
//         final response = await http.get(Uri.parse(
//           'https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=$symbol&apikey=$_apiKey',
//         ));

//         if (response.statusCode == 200) {
//           final data = json.decode(response.body);
//           if (data['Global Quote'] != null) {
//             final quote = data['Global Quote'];
//             results.add({
//               'symbol': symbol,
//               'name': symbol.replaceAll('.BO', '').replaceAll('.NS', ''),
//               'price': quote['05. price'],
//               'change': quote['10. change percent'].replaceAll('%', ''),
//               'exchange': _selectedExchange,
//             });
//           }
//         }
//       }

//       if (mounted) {
//         setState(() {
//           _stockResults = results;
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//         _showErrorSnackBar('Error: ${e.toString()}');
//       }
//     }
//   }

//   Future<void> _searchStocks(String query) async {
//     if (!mounted) return;

//     if (query.isEmpty) {
//       _fetchTopStocks();
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _searchPerformed = true;
//     });

//     try {
//       // Format symbol based on exchange
//       String symbol = _selectedExchange == 'NSE' 
//           ? '$query.NS' 
//           : '$query.BO';

//       final response = await http.get(Uri.parse(
//         'https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=$symbol&apikey=$_apiKey',
//       ));

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['Global Quote'] != null) {
//           final quote = data['Global Quote'];
//           if (mounted) {
//             setState(() {
//               _stockResults = [{
//                 'symbol': symbol,
//                 'name': query,
//                 'price': quote['05. price'],
//                 'change': quote['10. change percent'].replaceAll('%', ''),
//                 'exchange': _selectedExchange,
//               }];
//               _isLoading = false;
//             });
//           }
//           return;
//         }
//       }

//       if (mounted) {
//         setState(() {
//           _stockResults = [];
//           _isLoading = false;
//         });
//         _showErrorSnackBar('Stock not found on $_selectedExchange');
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//         _showErrorSnackBar('Error: ${e.toString()}');
//       }
//     }
//   }

//   void _showErrorSnackBar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(message)),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Indian Stock Search'),
//         backgroundColor: Colors.orange.shade800,
//         actions: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: DropdownButton<String>(
//               value: _selectedExchange,
//               icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
//               dropdownColor: Colors.orange.shade700,
//               underline: Container(),
//               items: ['NSE', 'BSE'].map((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(
//                     value,
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                 );
//               }).toList(),
//               onChanged: (String? newValue) {
//                 if (newValue != null) {
//                   setState(() {
//                     _selectedExchange = newValue;
//                   });
//                   _fetchTopStocks();
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search $_selectedExchange stocks...',
//                 prefixIcon: const Icon(Icons.search),
//                 suffixIcon: IconButton(
//                   icon: const Icon(Icons.clear),
//                   onPressed: () {
//                     _searchController.clear();
//                     _fetchTopStocks();
//                   },
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(15),
//                   borderSide: BorderSide.none,
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[200],
//               ),
//               onChanged: (value) {
//                 if (value.length > 2) {
//                   _searchStocks(value);
//                 }
//               },
//             ),
//           ),
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : _stockResults.isEmpty
//                     ? Center(
//                         child: Text(
//                           _searchPerformed
//                               ? 'No stocks found on $_selectedExchange'
//                               : 'Loading top $_selectedExchange stocks...',
//                           style: const TextStyle(fontSize: 16),
//                         ),
//                       )
//                     : ListView.builder(
//                         itemCount: _stockResults.length,
//                         itemBuilder: (context, index) {
//                           final stock = _stockResults[index];
//                           final change = double.tryParse(stock['change'] ?? '0') ?? 0;
//                           final isPositive = change >= 0;
                          
//                           return Card(
//                             margin: const EdgeInsets.symmetric(
//                                 horizontal: 16, vertical: 8),
//                             elevation: 2,
//                             child: ListTile(
//                               title: Text(
//                                 stock['name'] ?? 'N/A',
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.bold),
//                               ),
//                               subtitle: Text(
//                                 '${stock['symbol']} • ${stock['exchange']}',
//                               ),
//                               trailing: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                 children: [
//                                   Text(
//                                     '₹${stock['price'] ?? 'N/A'}',
//                                     style: TextStyle(
//                                       color: isPositive
//                                           ? Colors.green
//                                           : Colors.red,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   Text(
//                                     '${isPositive ? '+' : ''}${stock['change']}%',
//                                     style: TextStyle(
//                                       color: isPositive
//                                           ? Colors.green
//                                           : Colors.red,
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//           ),
//         ],
//       ),
//     );
//   }
// }