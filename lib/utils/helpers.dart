import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';

import 'config.dart';

formatedTime({required int timeInSecond}) {
  int sec = timeInSecond % 60;
  int min = (timeInSecond / 60).floor();
  String minute = min.toString().length <= 1 ? "0$min" : "$min";
  String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
  return "$minute : $second";
}

showLoader() {
  return LinearProgressIndicator();
}

getAddressText(Position? pos) async {
  List<Placemark> placemarks = await placemarkFromCoordinates(
      pos?.latitude ?? 0.0, pos?.longitude ?? 0.0);
  Placemark place = placemarks[0];
  return place.street;
}

Future<bool> deleteVideo(path) async {
  await File(path).delete();
  return !await File(path).exists();
}

getLocalUserDetails() {
  var box = Hive.box("storage");
  return {
    "token": box.get("authKey"),
    "userName": box.get("userName"),
    "userEmail": box.get("userEmail")
  };
}

Box box = Hive.box(config.hiveBoxName);
Future<bool> deleteObj(int index) async {
  var data;
  data = box.get(index);
  print(data);
  bool isDeleted = await deleteVideo(data['filePath']);
  print(isDeleted);
  box.delete(index);
  return isDeleted;
}

String secondsToTime(double sec) {
  print(sec);
  Duration duration = Duration(seconds: sec.toInt());
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "$twoDigitMinutes:$twoDigitSeconds";
}
