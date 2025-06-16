import 'package:flutter/material.dart';

class MyBrowser extends StatefulWidget {
  const MyBrowser({super.key});

  @override
  State<MyBrowser> createState() => _MyBrowserState();
}

class _MyBrowserState extends State<MyBrowser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Browser"),
        backgroundColor: Colors.transparent,
      ),
      body: Column(children: [_BrowserFld()]),
    );
  }

  Container _BrowserFld() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const TextField(
            decoration: InputDecoration(
              hintText: "Search...",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 16.0),
          const Center(child: Text("Browser Page Content Here")),
        ],
      ),
    );
  }
}
