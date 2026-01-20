import 'package:flutter/material.dart';

class HostPage extends StatelessWidget {
  const HostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Host Page')),
      body: Center(
        child: ElevatedButton(onPressed: () {}, child: Text("Test")),
      ),
    );
  }
}
