import 'dart:isolate';

import 'package:flutter/material.dart';

class IsolateExample extends StatefulWidget {
  const IsolateExample({super.key});

  @override
  IsolateExampleState createState() => IsolateExampleState();
}

class IsolateExampleState extends State<IsolateExample> {
  String _result = "Result will appear here";
  bool _isProcessing = false;

  // Function to calculate Fibonacci (just as an example of a CPU-intensive task)
  static int fibonacci(int n) {
    if (n <= 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
  }

  // Function to be executed by the Isolate
  static void calculateFibonacci(SendPort sendPort) {
    int result = fibonacci(40); // Fibonacci(40) is a heavy task
    sendPort.send(result); // Send the result back to the main isolate
  }

  // Function to start the isolate and perform the computation
  Future<void> _startIsolate() async {
    setState(() {
      _isProcessing = true;
      _result = "Processing...";
    });

    // Create a ReceivePort to receive messages from the isolate
    ReceivePort receivePort = ReceivePort();

    // Spawn a new isolate
    await Isolate.spawn(calculateFibonacci, receivePort.sendPort);

    // Listen for the result sent from the isolate
    receivePort.listen((data) {
      setState(() {
        _result = "Fibonacci(40) = $data";
        _isProcessing = false;
      });
      receivePort
          .close(); // Close the ReceivePort after the message is received
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Isolate Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (_isProcessing) const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              _result,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isProcessing ? null : _startIsolate,
              child: const Text("Start Calculation"),
            ),
          ],
        ),
      ),
    );
  }
}
