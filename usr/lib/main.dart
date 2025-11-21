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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
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

  void _calculate() {
    String exp = _controller.text.replaceAll(' ', '');
    if (exp.isEmpty) return;

    try {
      // Logic to fix the C++ code's problem (Operator Precedence)
      // We use a stack to handle multiplication before addition/subtraction
      List<int> stack = [];
      int currentNumber = 0;
      String sign = '+'; // Previous operator
      
      for (int i = 0; i < exp.length; i++) {
        String char = exp[i];
        
        // Build the number
        if (RegExp(r'[0-9]').hasMatch(char)) {
          currentNumber = currentNumber * 10 + int.parse(char);
        }
        
        // If operator or end of string, process the number
        if (!RegExp(r'[0-9]').hasMatch(char) || i == exp.length - 1) {
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
        _result = "Result: $sum";
        _steps = "Stack after precedence: $stack";
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
      appBar: AppBar(title: const Text("Expression Evaluator")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Problem: The original code evaluated 12+32*17 as (12+32)*17 = 748.\n\n"
                  "Solution: We use a stack to handle operator precedence (* before +).\n"
                  "Correct Result: 12 + (32*17) = 12 + 544 = 556.",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Expression",
                border: OutlineInputBorder(),
                hintText: "12+32*17",
              ),
              keyboardType: TextInputType.numberWithOptions(signed: true),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text("Calculate Correctly", style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 24),
            Text(
              _result,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _steps,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
