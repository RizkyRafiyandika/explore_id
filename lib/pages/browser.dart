import 'package:explore_id/colors/color.dart';
import 'package:flutter/material.dart';

class MyBrowser extends StatefulWidget {
  const MyBrowser({super.key});

  @override
  State<MyBrowser> createState() => _MyBrowserState();
}

class _MyBrowserState extends State<MyBrowser> {
  final TextEditingController browserController = TextEditingController();
  bool _isTextFilled = false;

  @override
  void initState() {
    super.initState();
    // Listen to changes in the text field
    browserController.addListener(() {
      setState(() {
        _isTextFilled = browserController.text.isNotEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(children: [_browserField()]),
      ),
    );
  }

  Widget _browserField() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Row(
        children: [
          // TextField
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 4), // changes position of shadow
                  ),
                ],
              ),
              child: TextField(
                controller: browserController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: tdwhitepure,
                  hintText: "Search...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // Search button
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder:
                (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
            child:
                _isTextFilled
                    ? Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          print("Searching: ${browserController.text}");
                        },

                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: tdwhiteblue,
                          ),
                        ),
                      ),
                    )
                    : const SizedBox.shrink(key: ValueKey("empty")),
          ),
        ],
      ),
    );
  }
}
