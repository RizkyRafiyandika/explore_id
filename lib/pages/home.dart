import 'package:explore_id/pages/profile.dart';
import 'package:flutter/material.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  final List<String> imagePaths = ['assets/Air Terjun,Sumba.jpeg'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: EdgeInsets.only(
            top: 10,
          ), // atur jarak satu sisi menggunakan only
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage('assets/Profile.png'),
                radius: 20,
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    'Username',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(width: 200),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.notifications_none, size: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
