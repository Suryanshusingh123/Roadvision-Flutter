import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:battery_plus/battery_plus.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:roadvisionflutter/components/toast_messages.dart';
import 'package:roadvisionflutter/screens/home/instructions.dart';
import 'package:roadvisionflutter/screens/recording/recording_complete.dart';
import 'package:roadvisionflutter/utils/colors.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_frame_extractor/video_frame_extractor.dart';

import '../../utils/config.dart';
import '../../utils/helpers.dart';

class Recording extends StatefulWidget {
  const Recording({Key? key}) : super(key: key);

  @override
  State<Recording> createState() => _RecordingState();
}

class _RecordingState extends State<Recording> {
  var battery = Battery();
  int batterylevel = 100;
  bool controls_hidden = false;
  late CameraController camera_controller;
  Completer<GoogleMapController> _controller = Completer();
  bool camera_preview_major = false;
  Position? currPosition;
  bool is_currposition_available = false;
  late Box box;
  Timer? _timer = null;
  int deltaForTimer = 1000; // in milliseconds
  double _elapsedTime = 0.0;
  var positionDetails = [];
  Position? initPosition = null;
  bool is_capturing = false;
  late GoogleMapController mapsController;
  bool isProcessing = true;
  bool show_instructions_first_time = true;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  double markerSize = 5.0;
  late BitmapDescriptor maps_start_icon;
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  double distance_travelled = 0.0;
  Map<String, dynamic> summary = {};
  List<Position?> start_pause_end = [];
  String polylineId = 'PolyLineId';
  List<String> deviceOrientations = ['PotraitUp', 'PotraitDown'];
  @override
  void initState() {
    super.initState();
    print(
        "********************************** Init State called **********************************");
    getCurrentPosition();
    initPositionStream();
    initCameraController();
    setupHive();
    initMapMarkerIcon();
    battery.onBatteryStateChanged.listen((BatteryState state) async {
      batterylevel = await battery.batteryLevel;
      setState(() {});
    });
  }

  initMapMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(markerSize, markerSize)),
            'assets/icons/maps_start.png')
        .then((d) {
      maps_start_icon = d;
    });
  }

  addPolyline(Position? point) {
    polylineCoordinates
        .add(LatLng(point?.latitude ?? 0.0, point?.longitude ?? 0.0));

    setState(() {
      _polylines.add(Polyline(
          width: 5,
          polylineId: PolylineId(polylineId),
          color: celticBlue,
          points: polylineCoordinates));
    });
  }

  getCurrentPosition() {
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((pos) {
      setState(() {
        currPosition = pos;
        is_currposition_available = true;
      });
    });
  }

  initPositionStream() {
    GeolocatorPlatform.instance
        .getPositionStream(
            locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.best, distanceFilter: 1))
        .listen((pos) {
      if (currPosition != null && camera_controller.value.isRecordingVideo) {
        distance_travelled += Geolocator.distanceBetween(
            currPosition?.latitude ?? 0.0,
            currPosition?.longitude ?? 0.0,
            pos.latitude,
            pos.longitude);
      }
      setState(() {
        currPosition = pos;
        isProcessing = false;
        is_currposition_available = true;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    mapsController.dispose();
    camera_controller.dispose();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
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
                      ? getCameraPreview(camera_controller, size)
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
                                    ? getCameraPreview(camera_controller, size)
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
              : show_instructions_first_time
                  ? const Instructions()
                  : Container(
                      width: size.width,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 18),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 4,
                                offset: Offset(0, -2))
                          ],
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(10))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.fiber_manual_record,
                                color: recodingInProgress,
                                size: 15,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              NativeDeviceOrientedWidget(
                                fallback: (BuildContext) {
                                  return const Text(" ");
                                },
                              ),
                              Text(
                                "Capture in Progress",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: recodingInProgress,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              isProcessing
                                  ? const SizedBox(
                                      height: 15,
                                      width: 15,
                                      child: CircularProgressIndicator())
                                  : const Text(" "),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Divider(),
                          Text(currPosition?.toString() ?? "Not init"),
                          Column(
                            children: [
                              getDetailsTextWidget(
                                  'Time Elapsed',
                                  formatedTime(
                                      timeInSecond: _elapsedTime.round()),
                                  Icons.watch_later_outlined),
                              getDetailsTextWidget(
                                  'Distance Covered',
                                  (distance_travelled.round() / 1000)
                                          .toString() +
                                      ' Km',
                                  Icons.directions_car),
                              getDetailsTextWidget(
                                  'Current Speed',
                                  (currPosition?.speed.round() ?? 0.0 * 3.6)
                                          .toString() +
                                      ' Km/hr',
                                  Icons.speed_outlined),
                            ],
                          ),
                        ],
                      ),
                    ),
          controls_hidden
              ? Text(" ")
              : Container(
                  height: 100,
                  padding:
                      EdgeInsets.only(top: 16, bottom: 24, left: 16, right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: camera_controller.value.isRecordingVideo
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            camera_controller.value.isRecordingPaused
                                ? SizedBox(
                                    width: size.width * 0.35,
                                    height: size.height * 0.08,
                                    child: TextButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(backgroundGrey)),
                                        onPressed: () {
                                          setState(() {
                                            isProcessing = true;
                                            polylineCoordinates = [];
                                            polylineId =
                                                generateRandomString(6);
                                          });
                                          camera_controller
                                              .resumeVideoRecording();
                                          setState(() {
                                            isProcessing = false;
                                          });
                                          saveCurrentPosition(currPosition);
                                          add_marker(
                                              "resume" +
                                                  generateRandomString(3),
                                              currPosition,
                                              maps_start_icon);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.pause,
                                                color: bangladeshGreen,
                                              ),
                                              Text(
                                                "Resume",
                                                style: TextStyle(
                                                    color: bangladeshGreen),
                                              )
                                            ],
                                          ),
                                        )),
                                  )
                                : SizedBox(
                                    width: size.width * 0.4,
                                    height: size.height * 0.08,
                                    child: TextButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(backgroundGrey)),
                                        onPressed: () {
                                          print("Pause capturing pressed");
                                          setState(() {
                                            isProcessing = true;
                                            polylineCoordinates = [];
                                          });
                                          camera_controller
                                              .pauseVideoRecording();
                                          saveCurrentPosition(currPosition);
                                          setState(() {
                                            isProcessing = false;
                                          });
                                          BitmapDescriptor pauseIcon;
                                          BitmapDescriptor.fromAssetImage(
                                                  const ImageConfiguration(
                                                      size: Size(15, 15)),
                                                  'assets/icons/maps_end.png')
                                              .then((d) {
                                            pauseIcon = d;
                                            add_marker(
                                                "pause" +
                                                    generateRandomString(3),
                                                currPosition,
                                                pauseIcon);
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.pause),
                                              Text(
                                                "Pause",
                                                style: TextStyle(
                                                    color: celticBlue),
                                              )
                                            ],
                                          ),
                                        )),
                                  ),
                            SizedBox(
                              width: size.width * 0.45,
                              height: size.height * 0.1,
                              child: TextButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            stopRecording)),
                                onPressed: () async {
                                  setState(() {
                                    isProcessing = true;
                                  });
                                  BitmapDescriptor pauseIcon;
                                  BitmapDescriptor.fromAssetImage(
                                          ImageConfiguration(
                                              size: Size(15, 15)),
                                          'assets/icons/maps_end.png')
                                      .then((d) {
                                    pauseIcon = d;
                                    add_marker("stop" + generateRandomString(3),
                                        currPosition, pauseIcon);
                                  });
                                  XFile file = await camera_controller
                                      .stopVideoRecording();
                                  saveCurrentPosition(currPosition);
                                  final directory =
                                      await getApplicationDocumentsDirectory();
                                  final path = directory.path;
                                  var uuid = const Uuid();
                                  String uid = uuid.v4();
                                  //Note : Uid is used in next screen to delete Keep the var
                                  File newFile = File('$path/$uid.mp4');
                                  await file.saveTo(newFile.path);
                                  MediaInfo? mediaInfo =
                                      await VideoCompress.compressVideo(
                                    newFile.path,
                                    quality: VideoQuality.DefaultQuality,
                                    deleteOrigin: true,
                                  );

                                  // await VideoFrameExtractor.fromFile(
                                  //   imagesCount: 4,
                                  //   onProgress: (progress) {},
                                  //   video: File(mediaInfo!.path!),
                                  //   destinationDirectoryPath:
                                  //       '/storage/emulated/0/Download',
                                  // );

                                  final info = await VideoCompress.getMediaInfo(
                                      mediaInfo!.path!);
                                  print(info.path);

                                  //TODO: Add Email / user id something of the user to send in details
                                  summary['start_end_positions'] =
                                      start_pause_end;
                                  summary['elapsed_time'] = _elapsedTime;
                                  summary['distance_covered'] =
                                      distance_travelled;
                                  summary['video_file_path'] = mediaInfo.path;
                                  summary['video_file_size'] =
                                      mediaInfo!.filesize;
                                  summary['position_details'] = positionDetails;
                                  summary['final_position'] = currPosition;
                                  summary['markers'] = markers;
                                  summary['polylineCoordinates'] =
                                      polylineCoordinates;
                                  summary['_polylines'] = _polylines;
                                  summary['uid'] = uid.toString();
                                  String startAddress =
                                      await getAddressText(start_pause_end[0]);
                                  String endAddress = await getAddressText(
                                      start_pause_end[
                                          start_pause_end.length - 1]);
                                  summary['end_address'] = endAddress;
                                  summary['start_end_address_string'] =
                                      startAddress + '_' + endAddress;
                                  summary['video_title'] = endAddress + '.mp4';
                                  //Note : Uid is used in next screen to delete Keep the var
                                  Map<dynamic, dynamic> userDetails =
                                      getLocalUserDetails();
                                  DateTime curr = DateTime.now();
                                  DateFormat('yyyy-MM-dd – kk:mm:ss')
                                      .format(DateTime.now());
                                  await box.add({
                                    "uid": uid.toString(),
                                    "positionDetails": positionDetails,
                                    "filePath": mediaInfo.path,
                                    "videoLength": _elapsedTime,
                                    "title": endAddress + '.mp4',
                                    "isUploaded": false,
                                    "userEmail": userDetails['userEmail'],
                                    "userName": userDetails['userName'],
                                    "createdAt":
                                        DateFormat('d MMMM y – kk:mm:ss')
                                            .format(DateTime.now())
                                            .toString(),
                                    "startAddress": startAddress,
                                    "endAddress": endAddress,
                                  });

                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              RecordingComplete(
                                                summary: summary,
                                              )));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.square,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        "Stop Capturing",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    color: Colors.grey[200]),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.close,
                                          color: bloodOrange,
                                          size: 20,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          "Cancel",
                                          style: TextStyle(
                                              color: bloodOrange,
                                              fontWeight: FontWeight.w400),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  if (!is_currposition_available) {
                                    showSnackBar(
                                        context, "Wait for Maps to Load",
                                        isError: true);
                                    // showErrorMessage("Wait for Maps to Load");
                                    return;
                                  }
                                  setState(() {
                                    isProcessing = true;
                                    show_instructions_first_time = false;
                                  });
                                  camera_controller.startVideoRecording();
                                  setState(() {
                                    isProcessing = false;
                                  });
                                  saveCurrentPosition(currPosition);
                                  summary['starting_time'] = DateTime.now();
                                  summary['initial_position'] = currPosition;
                                  add_marker("Starting Point marker",
                                      currPosition, maps_start_icon);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      color: celticBlue),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                              fontWeight: FontWeight.w400),
                                        )
                                      ],
                                    ),
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

  String generateRandomString(int len) {
    var r = Random();
    return String.fromCharCodes(
        List.generate(len, (index) => r.nextInt(33) + 89));
  }

  void add_marker(String id, Position? pos, marker_icon) {
    final MarkerId markerId = MarkerId(id);
    Marker marker = Marker(
      markerId: markerId,
      icon: marker_icon,
      position: LatLng(pos?.latitude ?? 0.0, pos?.longitude ?? 0.0),
      infoWindow: const InfoWindow(title: "Starting point", snippet: ''),
      onTap: () {
        // _onMarkerTapped(markerId);
      },
    );
    setState(() {
      // adding a new marker to map
      markers[markerId] = marker;
    });
  }

  saveCurrentPosition(Position? pos) {
    start_pause_end.add(pos);
  }

  getMaps() {
    return is_currposition_available
        ? GoogleMap(
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            initialCameraPosition: CameraPosition(
              target: LatLng(currPosition?.latitude ?? 0.0,
                  currPosition?.longitude ?? 0.0),
              zoom: config.mapsInitialZoom,
            ),
            markers: Set<Marker>.of(markers.values),
            polylines: _polylines,
            onMapCreated: (GoogleMapController controller) {
              if (!_controller.isCompleted) {
                _controller.complete(controller);
                mapsController = controller;
              }
            },
          )
        : Center(child: CircularProgressIndicator());
  }

  double currentZoom = 1.0;
  Future<void> zoomIn(CameraController controller) async {
    if (controller != null) {
      final maxZoom = await controller.getMaxZoomLevel();
      if (currentZoom < maxZoom) {
        print("zoomIn");
        final newZoom = currentZoom +
            0.5; // Increase the zoom level by 0.1 (adjust as needed)
        setState(() {
          controller.setZoomLevel(newZoom);
          currentZoom = newZoom;
        });
      }
    }
  }

// Function to zoom out
  void zoomOut(CameraController controller) {
    if (controller != null) {
      print("zoomOut");
      if (currentZoom > 1.0) {
        final newZoom = currentZoom -
            0.5; // Decrease the zoom level by 0.1 (adjust as needed)
        setState(() {
          controller.setZoomLevel(newZoom);
          currentZoom = newZoom;
        });
      }
    }
  }

  getCameraPreview(CameraController controller, Size size) {
    if (!controller.value.isInitialized) {
      return Container(
          height: 2,
          width: 2,
          child: const LinearProgressIndicator(
            color: Colors.grey,
          ));
    }
    return Container(
      width: size.width,
      child: CameraPreview(
        controller,
        child: Padding(
          padding: const EdgeInsets.only(top: 60, right: 40),
          child: camera_preview_major
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    InkWell(
                        onTap: () {
                          zoomIn(controller);
                        },
                        child: CircleAvatar(
                          child: Icon(Icons.zoom_in, color: Colors.white),
                        )),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: InkWell(
                          onTap: () {
                            zoomOut(controller);
                          },
                          child: CircleAvatar(
                            child: Icon(
                              Icons.zoom_out,
                              color: Colors.white,
                            ),
                          )),
                    ),
                  ],
                )
              : Container(),
        ),
      ),
    );
  }

  initCameraController() {
    camera_controller = CameraController(
        config.cameras[0], ResolutionPreset.high,
        enableAudio: false);
    camera_controller.initialize().then((_) {
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
            print('Handle other errors.');
            break;
        }
      }
    });
    camera_controller.addListener(() async {
      // camera_controller.value.isRecordingPaused
      if (camera_controller.value.isRecordingPaused) {
        if (_timer == null) {
          return;
        }
        _stopTimer();
        return;
      }
      if (camera_controller.value.isRecordingVideo) {
        polylineId = generateRandomString(6);
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

  void _startTimer() {
    _timer =
        Timer.periodic(Duration(milliseconds: deltaForTimer), (timer) async {
      setState(() {
        _elapsedTime += deltaForTimer / 1000;
      });
      final orientation = await NativeDeviceOrientationCommunicator()
          .orientation(useSensor: true);
      // print(deviceOrientaion);
      positionDetails.add([
        {
          "timeElapsed": _elapsedTime,
          "latitude": currPosition?.latitude ?? -1,
          "longitude": currPosition?.longitude ?? -1,
          "speed": currPosition?.speed ?? -1,
          "speedAcuracy": currPosition?.speedAccuracy ?? -1,
          "orientation": orientation.name
        }
      ]);
      addPolyline(currPosition);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {});
  }
  // void _resumeTimer()
  // {
  //   _timer?.
  // }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _elapsedTime = 0;
    });
  }

  Future<void> setupHive() async {
    Directory documentDir = await getApplicationSupportDirectory();
    setState(() {
      box = Hive.box(config.hiveBoxName);
    });
  }

  getDetailsTextWidget(String title, String valueText, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(100)),
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Icon(
                icon,
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Spacer(),
          Text(
            valueText,
            style:
                TextStyle(color: is_capturing ? bangladeshGreen : Colors.black),
          ),
        ],
      ),
    );
  }
}
