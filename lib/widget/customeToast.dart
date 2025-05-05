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
