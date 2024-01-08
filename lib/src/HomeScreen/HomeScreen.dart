import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:roadvisionflutter/screens/recording/recording_screen.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({required this.cameras});

  final List<CameraDescription> cameras;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: () async {
                  LocationPermission permission =
                      await Geolocator.checkPermission();
                  if (permission == LocationPermission.denied) {
                    Geolocator.requestPermission();
                    // Geolocator.requestTemporaryFullAccuracy(
                    //     purposeKey: 'SleekSitesKey');
                  }
                  await Permission.manageExternalStorage.request();
                  bool status =
                      await Permission.manageExternalStorage.isGranted;
                  print("is permission for external Storage?");
                  print(status);

                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => Recording()));
                },
                child: Text("Start Recording")),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
