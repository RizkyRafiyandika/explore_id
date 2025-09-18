import 'package:explore_id/colors/color.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

void customToast(String message, {Color backgroundColor = tdwhiteblue}) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: backgroundColor,
    textColor: tdwhite,
    fontSize: 16.0,
  );
}

void cutomeSneakBar(BuildContext context, String message) {
  final snackBar = SnackBar(
    content: Text(message),
    duration: const Duration(seconds: 2),
    backgroundColor: const Color.fromARGB(255, 255, 0, 0),
    action: SnackBarAction(onPressed: () {}, textColor: tdwhite, label: ''),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
