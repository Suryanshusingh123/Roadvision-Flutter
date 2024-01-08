// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:roadvisionflutter/utils/colors.dart';

import '../../utils/config.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var battery = Battery();
  int batterylevel = 100;
  bool controls_hidden = false;
  late CameraController controller;
  final Completer<GoogleMapController> _controller = Completer();
  bool camera_preview_major = false;
  Position? currPosition;
  bool is_currposition_available = false;
  // ignore: prefer_typing_uninitialized_variables
  late var box;
  // ignore: avoid_init_to_null
  Timer? _timer = null;
  int deltaForTimer = 100; // in milliseconds
  double _elapsedTime = 0.0;
  var positionDetails = [];

  @override
  void initState() {
    super.initState();
    battery.onBatteryStateChanged.listen((BatteryState state) async {
      batterylevel = await battery.batteryLevel;
      setState(() {});
    });
    initCameraController();
    initPositionStream();
  }

  initPositionStream() {
    GeolocatorPlatform.instance.getPositionStream().listen((pos) {
      setState(() {
        currPosition = pos;
        is_currposition_available = true;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                InkWell(
                  child: camera_preview_major
                      ? getCameraPreview(controller, size)
                      : getMaps(),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          camera_preview_major = !camera_preview_major;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.14),
                                      blurRadius: 4,
                                      spreadRadius: 1),
                                ],
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    camera_preview_major
                                        ? Icons.camera_alt_rounded
                                        : Icons.location_on,
                                    color: oxfordBlue,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(camera_preview_major
                                      ? "Camera View"
                                      : "Maps View"),
                                ],
                              ),
                            ),
                            Expanded(child: Container()),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 2, vertical: 2),
                                width: size.width / 3,
                                height: size.width / 3,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.14),
                                        blurRadius: 4,
                                        spreadRadius: 1),
                                  ],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: !camera_preview_major
                                    ? getCameraPreview(controller, size)
                                    : getMaps(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          controls_hidden
              ? const Text(" ")
              : Container(
                  width: size.width,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 4,
                            offset: const Offset(0, -2))
                      ],
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(10))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Mount your phone",
                        style: TextStyle(
                          fontSize: 20,
                          color: oxfordBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              controls_hidden = true;
                            });
                          },
                          child: const Text("Hide")),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          text:
                              "Mount your phone and make sure there is no obstruction in front of your phone camera. Tap Start Capturing once you are ready.",
                          style: TextStyle(
                            color: graniteGray,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        color: bangladeshGreen.withOpacity(0.1),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 17, vertical: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.traffic_outlined,
                              color: bangladeshGreen,
                            ),
                            const SizedBox(width: 9),
                            Flexible(
                              child: Text(
                                "Wear your seatbelt and follow traffic rules.",
                                style: TextStyle(
                                    color: bangladeshGreen,
                                    fontWeight: FontWeight.w500),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
          controls_hidden
              ? const Text(" ")
              : Container(
                  height: 100,
                  padding: const EdgeInsets.only(
                      top: 16, bottom: 24, left: 16, right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: Colors.grey[200]),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.close,
                                  color: bloodOrange,
                                  size: 20,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "Cancel",
                                  style: TextStyle(
                                      color: bloodOrange,
                                      fontWeight: FontWeight.w600),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: celticBlue),
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.fiber_manual_record,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  "Start Capturing",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  getMaps() {
    return is_currposition_available
        ? GoogleMap(
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            initialCameraPosition: CameraPosition(
              target: LatLng(currPosition?.latitude ?? 0.0,
                  currPosition?.longitude ?? 0.0),
              zoom: 14.4746,
            ),
            onMapCreated: (GoogleMapController controller) {
              if (!_controller.isCompleted) {
                _controller.complete(controller);
              }
            },
          )
        : const Center(child: CircularProgressIndicator());
  }

  getCameraPreview(CameraController controller, Size size) {
    if (!controller.value.isInitialized) {
      return const SizedBox(
          height: 2,
          width: 2,
          child: LinearProgressIndicator(
            color: Colors.grey,
          ));
    }
    return SizedBox(width: size.width, child: CameraPreview(controller));
  }

  initCameraController() {
    controller = CameraController(config.cameras[0], ResolutionPreset.high,
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
            break;
          default:
            // ignore: avoid_print
            print('Handle other errors.');
            break;
        }
      }
    });
  }

  Future<void> setupHive() async {
    Directory pathForHive = await getApplicationDocumentsDirectory();
    await Hive.openBox("locationBox",
        path: '${pathForHive.path}/HiveDirectory/');
    box = Hive.box('locationBox');
  }
}
