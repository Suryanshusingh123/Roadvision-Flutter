import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:roadvisionflutter/utils/colors.dart';

showErrorMessage(String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}

showSnackBar(BuildContext context, String msg, {bool isError: false}) {
  var snackBar = SnackBar(
    content: Text(msg),
    backgroundColor: isError ? Colors.redAccent : celticBlue,
    showCloseIcon: true,
  );
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
