import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../showRecordedVideos/ListRecordedVideos.dart';

class CameraScreen extends StatefulWidget {
  /// Default Constructor
  List<CameraDescription> cameras;
  CameraScreen({required this.cameras, Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  var positionDetails = [];
  var isRecording = false;
  Timer? _timer = null;
  int deltaForTimer = 100; // in milliseconds
  double _elapsedTime = 0.0;
  late Position? position;
  late var box;
  StreamSubscription<Position>? _positionStreamSubscription;

  void _startTimer() {
    _timer =
        Timer.periodic(Duration(milliseconds: deltaForTimer), (timer) async {
      setState(() {
        _elapsedTime += deltaForTimer / 1000;
      });
      print(position);
      positionDetails.add([
        {
          "timeElapsed": _elapsedTime,
          "latitude": position?.latitude ?? -1,
          "longitude": position?.longitude ?? -1,
          "speed": position?.speed ?? -1,
          "speedAcuracy": position?.speedAccuracy ?? -1
        }
      ]);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {});
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _elapsedTime = 0;
    });
  }

  Future<void> setupHive() async {
    Directory pathForHive = await getApplicationDocumentsDirectory();
    await Hive.openBox("locationBox",
        path: pathForHive.path + '/HiveDirectory/');
    box = Hive.box('locationBox');
  }

  @override
  void initState() {
    super.initState();
    setupHive();
    _positionStreamSubscription =
        GeolocatorPlatform.instance.getPositionStream().listen((pos) {
      setState(() {
        position = pos;
      });
    });

    controller = CameraController(
        this.widget.cameras[0], ResolutionPreset.ultraHigh,
        enableAudio: false);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print('User denied camera access.');
            break;
          default:
            print('Handle other errors.');
            break;
        }
      }
    });
    controller.addListener(() async {
      if (controller.value.isRecordingVideo) {
        _startTimer();
      } else {
        if (_timer == null) {
          return;
        }
        _stopTimer();
        // _resetTimer();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    _positionStreamSubscription
        ?.cancel()
        .then((value) => {print("stream cancelled")});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if (!controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      // appBar: AppBar(),
      body: Column(children: [
        Container(
          height: size.height * 0.75,
          width: size.width,
          child: CameraPreview(controller),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Text(position.toString()),
            // Text(
            //   _elapsedTime.round().toString(),
            //   style: TextStyle(color: Colors.white),
            // ),
            RecodingButtons(size),
          ],
        )
      ]),
    );
  }

  Widget RecodingButtons(Size size) {
    return Container(
      height: size.height * 0.2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ElevatedButton(
              onPressed: null,
              child: Icon(
                Icons.pause,
                size: 30,
                color: Colors.white,
              )),
          Padding(
            padding: const EdgeInsets.all(40),
            child: !isRecording
                ? Container(
                    child: MaterialButton(
                      shape: const CircleBorder(
                        side: BorderSide(
                          width: 3,
                          color: Colors.grey,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: const Text(""),
                      color: Colors.red,
                      textColor: Colors.amber,
                      onPressed: () {
                        setState(() {
                          isRecording = true;
                          controller.startVideoRecording();
                        });
                      },
                    ),
                  )
                : Container(
                    width: 80,
                    height: 80,
                    child: MaterialButton(
                      shape: const CircleBorder(
                        side: BorderSide(
                          width: 2,
                          color: Colors.grey,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(200),
                        ),
                        child: const Icon(
                          Icons.stop,
                          color: Colors.black54,
                          size: 40,
                        ),
                      ),
                      color: Colors.white,
                      textColor: Colors.amber,
                      onPressed: () async {
                        setState(() {
                          isRecording = false;
                        });
                        XFile file = await controller.stopVideoRecording();
                        print(file.path);
                        final directory =
                            await getApplicationDocumentsDirectory();
                        final path = directory.path;
                        var uuid = Uuid();
                        String uid = uuid.v1();
                        File newFile = File('$path/$uid.mp4');
                        file.saveTo(newFile.path);
                        box.put(uid, {
                          "positionDetails": positionDetails,
                          "filePath": newFile.path,
                          "videoLength": _elapsedTime,
                        });
                        _resetTimer();
                      },
                    ),
                  ),
          ),
          const SizedBox(
            width: 20,
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => RecordVideoList()));
            },
            child: const Icon(
              Icons.folder,
              size: 30,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
