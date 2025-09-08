import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(), // biar konsisten dark mode
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    RunningTradeResponsivePage(),
    OrderBookPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: "Running Trade",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Order Book",
          ),
        ],
      ),
    );
  }
}

class RunningTradeResponsivePage extends StatefulWidget {
  const RunningTradeResponsivePage({super.key});

  @override
  State<RunningTradeResponsivePage> createState() =>
      _RunningTradeResponsivePageState();
}

class _RunningTradeResponsivePageState
    extends State<RunningTradeResponsivePage> {
  final List<Map<String, dynamic>> trades = [];
  String? selectedCode;
  Timer? _timer;
  final Random _random = Random();

  final List<String> codes = ["BUVA", "BRMS", "NICL", "HRUM", "ASSA", "MINE"];

  @override
  void initState() {
    super.initState();

    // Timer jalan setiap 100 ms
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final count = _random.nextInt(8) + 3; // 3 sampai 10 row baru
      for (int i = 0; i < count; i++) {
        _addRandomTrade();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _addRandomTrade() {
    final now = DateTime.now();
    final code = codes[_random.nextInt(codes.length)];
    final price = 100 + _random.nextInt(1000);
    final lot = 1 + _random.nextInt(100);
    final change = _random.nextInt(41) - 20; // -20 sampai +20
    final percent = (change / price) * 100;
    final side = _random.nextBool() ? "BUY" : "SELL";

    setState(() {
      trades.insert(0, {
        "time": "${now.hour}:${now.minute}:${now.second}",
        "code": code,
        "price": price,
        "lot": lot,
        "change": change,
        "percent": percent,
        "side": side,
      });

      // Batasi biar list tidak terlalu panjang (misal max 100 row)
      if (trades.length > 100) {
        trades.removeLast();
      }
    });
  }

  Color _getColor(num value) {
    if (value > 0) return Colors.green;
    if (value < 0) return Colors.red;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    // filter data berdasarkan code
    final filteredTrades = selectedCode == null
        ? trades
        : trades.where((t) => t["code"] == selectedCode).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text("Running Trade"),
      ),
      // appBar: AppBar(
      //   backgroundColor: Colors.grey[900],
      //   // title: const Text("Running Trade"),
      // ),
      body: Column(
        children: [
          // Filter bar
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[850],
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    dropdownColor: Colors.grey[900],
                    value: selectedCode,
                    hint: const Text(
                      "Select Code...",
                      style: TextStyle(color: Colors.white),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child:
                            Text("All", style: TextStyle(color: Colors.white)),
                      ),
                      ...codes.map((code) => DropdownMenuItem<String>(
                            value: code,
                            child: Text(code,
                                style: const TextStyle(color: Colors.white)),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCode = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Icon(Icons.filter_list, color: Colors.white),
                const SizedBox(width: 10),
                Icon(Icons.settings, color: Colors.white),
              ],
            ),
          ),

          // Tabel responsive
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(Colors.grey[850]),
                  //  columnSpacing: 24,
                  dataRowMinHeight: 36,
                  dataRowMaxHeight: 44,
                  columns: const [
                    DataColumn(
                        label: Text("Time",
                            style: TextStyle(color: Colors.white))),
                    DataColumn(
                        label: Text("Code",
                            style: TextStyle(color: Colors.white))),
                    DataColumn(
                        label: Text("Price",
                            style: TextStyle(color: Colors.white))),
                    DataColumn(
                        label:
                            Text("Lot", style: TextStyle(color: Colors.white))),
                    DataColumn(
                        label: Text("Change",
                            style: TextStyle(color: Colors.white))),
                    DataColumn(
                        label:
                            Text("%", style: TextStyle(color: Colors.white))),
                    DataColumn(
                        label: Text("Side",
                            style: TextStyle(color: Colors.white))),
                  ],
                  rows: filteredTrades.map((trade) {
                    return DataRow(
                      cells: [
                        DataCell(Text(trade["time"],
                            style: const TextStyle(
                                color: Colors.white, fontSize: 10))),
                        DataCell(Text(trade["code"],
                            style: const TextStyle(
                                color: Colors.white, fontSize: 10))),
                        DataCell(Text(
                          "${trade["price"]}",
                          style: TextStyle(
                              color: _getColor(trade["change"]), fontSize: 10),
                        )),
                        DataCell(Text("${trade["lot"]}",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 10))),
                        DataCell(Text("${trade["change"]}",
                            style: TextStyle(
                                color: _getColor(trade["change"]),
                                fontSize: 10))),
                        DataCell(Text(
                            "(${trade["percent"].toStringAsFixed(2)}%)",
                            style: TextStyle(
                                color: _getColor(trade["percent"]),
                                fontSize: 10))),
                        DataCell(Text(
                          trade["side"],
                          style: TextStyle(
                              color: trade["side"] == "BUY"
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 10),
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderBookPage extends StatefulWidget {
  const OrderBookPage({super.key});

  @override
  State<OrderBookPage> createState() => _OrderBookPageState();
}

class _OrderBookPageState extends State<OrderBookPage> {
  final Random _random = Random();
  Timer? _timer;

  // dummy kode saham
  final List<String> stockCodes = ["KPIG", "BBCA", "BBRI", "TLKM", "ASII"];
  String selectedCode = "KPIG";

  // Dummy data bid/offer
  final List<Map<String, dynamic>> orderBook = [];

  @override
  void initState() {
    super.initState();
    _generateInitialData();

    // update data tiap 500 ms
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _updateRandomData();
    });
  }

  void _generateInitialData() {
    orderBook.clear();
    for (int i = 0; i < 10; i++) {
      orderBook.add({
        "bidPrice": 190 + i,
        "bidLot": _random.nextInt(50000) + 1000,
        "bidFreq": _random.nextInt(100),
        "offerPrice": 200 + i,
        "offerLot": _random.nextInt(50000) + 1000,
        "offerFreq": _random.nextInt(100),
      });
    }
  }

  void _updateRandomData() {
    setState(() {
      int index = _random.nextInt(orderBook.length);
      orderBook[index] = {
        "bidPrice": orderBook[index]["bidPrice"],
        "bidLot": _random.nextInt(60000) + 1000,
        "bidFreq": _random.nextInt(100),
        "offerPrice": orderBook[index]["offerPrice"],
        "offerLot": _random.nextInt(60000) + 1000,
        "offerFreq": _random.nextInt(100),
      };
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.grey[900],
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Ganti KPIG jadi dropdown
          DropdownButton<String>(
            dropdownColor: Colors.grey[900],
            value: selectedCode,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            style: const TextStyle(color: Colors.white, fontSize: 16),
            underline: Container(),
            onChanged: (String? newValue) {
              setState(() {
                selectedCode = newValue!;
                _generateInitialData(); // reset data saat ganti kode
              });
            },
            items: stockCodes.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Prv 216", style: TextStyle(color: Colors.red)),
              Text("Ch -18 (-8.33%)", style: TextStyle(color: Colors.red)),
              Text("Avg 206", style: TextStyle(color: Colors.white)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Open 216", style: TextStyle(color: Colors.white)),
              Text("High 218", style: TextStyle(color: Colors.green)),
              Text("Low 198", style: TextStyle(color: Colors.red)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Lot 1.03M", style: TextStyle(color: Colors.white)),
              Text("Val 21.24B", style: TextStyle(color: Colors.white)),
              Text("Freq 8.04K", style: TextStyle(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderBookTable() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Table(
        border: TableBorder.all(color: Colors.grey.shade800),
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(2),
          3: FlexColumnWidth(2),
          4: FlexColumnWidth(2),
          5: FlexColumnWidth(1),
        },
        children: [
          const TableRow(
            decoration: BoxDecoration(color: Colors.black),
            children: [
              Padding(
                padding: EdgeInsets.all(4),
                child: Text("Freq",
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center),
              ),
              Padding(
                padding: EdgeInsets.all(4),
                child: Text("Lot",
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center),
              ),
              Padding(
                padding: EdgeInsets.all(4),
                child: Text("Bid",
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center),
              ),
              Padding(
                padding: EdgeInsets.all(4),
                child: Text("Offer",
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center),
              ),
              Padding(
                padding: EdgeInsets.all(4),
                child: Text("Lot",
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center),
              ),
              Padding(
                padding: EdgeInsets.all(4),
                child: Text("Freq",
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center),
              ),
            ],
          ),
          ...orderBook.map((row) {
            return TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text("${row["bidFreq"]}",
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center),
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text("${row["bidLot"]}",
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center),
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text("${row["bidPrice"]}",
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center),
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text("${row["offerPrice"]}",
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center),
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text("${row["offerLot"]}",
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center),
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text("${row["offerFreq"]}",
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center),
                ),
              ],
            );
          })
        ],
      ),
    );
  }

  Widget _buildStrengthBar(double strength) {
    return Column(
      children: [
        Container(
          height: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: const LinearGradient(
              colors: [
                Colors.red,
                Colors.red,
                Colors.green,
                Colors.green,
              ],
              stops: [0.0, 0.48, 0.52, 1.0], // transisi halus di tengah
            ),
          ),
          child: FractionallySizedBox(
            alignment:
                strength >= 0 ? Alignment.centerRight : Alignment.centerLeft,
            widthFactor: (strength.abs() / 100).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Strength: ${strength.toStringAsFixed(1)}%",
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text("Order Book"),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildOrderBookTable()),
          _buildStrengthBar(30),
        ],
      ),
    );
  }
}
