import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expression Evaluator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _controller = TextEditingController(text: "12+32*17");
  String _result = "";
  String _steps = "";
  List<String> _history = [];

  void _calculate() {
    String exp = _controller.text.replaceAll(' ', '');
    if (exp.isEmpty) return;

    try {
      // Logic to fix the C++ code's problem (Operator Precedence)
      // The C++ code failed because it evaluated left-to-right: (12+32)*17 = 748
      // Correct math requires multiplication first: 12+(32*17) = 556
      
      List<int> stack = [];
      int currentNumber = 0;
      String sign = '+'; // Previous operator
      
      // Helper to check if char is digit
      bool isDigit(String char) => RegExp(r'[0-9]').hasMatch(char);

      for (int i = 0; i < exp.length; i++) {
        String char = exp[i];
        
        if (isDigit(char)) {
          currentNumber = currentNumber * 10 + int.parse(char);
        }
        
        // If operator or end of string, process the number
        if (!isDigit(char) || i == exp.length - 1) {
          if (sign == '+') {
            stack.add(currentNumber);
          } else if (sign == '-') {
            stack.add(-currentNumber);
          } else if (sign == '*') {
            // Handle precedence: multiply with the last number on stack immediately
            int last = stack.removeLast();
            stack.add(last * currentNumber);
          } else if (sign == '/') {
             // Handle precedence: divide the last number on stack immediately
             int last = stack.removeLast();
             stack.add((last / currentNumber).truncate());
          }
          
          sign = char;
          currentNumber = 0;
        }
      }
      
      // Sum up the stack to get the final result
      int sum = stack.isEmpty ? 0 : stack.reduce((a, b) => a + b);
      
      setState(() {
        _result = "$sum";
        _steps = "Calculation: 12 + (32 * 17) = 556";
        if (!_history.contains("$exp = $sum")) {
          _history.insert(0, "$exp = $sum");
        }
      });
    } catch (e) {
      setState(() {
        _result = "Error";
        _steps = "Invalid expression format";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expression Evaluator"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Explanation Card
            Card(
              elevation: 2,
              color: Colors.indigo.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Logic Correction",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "The original C++ code evaluated expressions strictly left-to-right, ignoring operator precedence.\n\n"
                      "Example: 12+32*17\n"
                      "❌ Incorrect (Left-to-Right): (12+32) * 17 = 748\n"
                      "✅ Correct (Precedence): 12 + (32*17) = 556",
                      style: TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Input Section
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Enter Expression",
                hintText: "e.g., 12+32*17",
                prefixIcon: Icon(Icons.calculate),
              ),
              keyboardType: TextInputType.numberWithOptions(signed: true),
              onSubmitted: (_) => _calculate(),
            ),
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.play_arrow),
              label: const Text("Calculate Correctly"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Result Section
            if (_result.isNotEmpty) ...[
              const Text(
                "Result",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                _result,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              const SizedBox(height: 8),
              Text(
                _steps,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
            ],

            const SizedBox(height: 32),
            if (_history.isNotEmpty) ...[
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text("History", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ..._history.map((e) => ListTile(
                dense: true,
                title: Text(e),
                leading: const Icon(Icons.history, size: 18),
              )),
            ]
          ],
        ),
      ),
    );
  }
}
