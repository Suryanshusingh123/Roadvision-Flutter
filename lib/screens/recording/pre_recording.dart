import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:roadvisionflutter/screens/recording/recording_screen.dart';
import 'package:roadvisionflutter/utils/config.dart';
import 'package:roadvisionflutter/utils/helpers.dart';

import '../../utils/colors.dart';

class PreRecordingScreen extends StatefulWidget {
  const PreRecordingScreen({Key? key}) : super(key: key);

  @override
  State<PreRecordingScreen> createState() => _PreRecordingScreenState();
}

class _PreRecordingScreenState extends State<PreRecordingScreen> {
  Position? currPosition;
  bool is_currposition_available = false;
  late GoogleMapController mapsController;
  Completer<GoogleMapController> _controller = Completer();
  late String currAddress;
  var battery = Battery();
  late int battery_level;
  bool is_battery_available = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentPosition();
    battery.batteryLevel.then((lev) {
      print("battery level");
      print(lev);
      setState(() {
        battery_level = lev;
        is_battery_available = true;
      });
    });
  }

  getCurrentPosition() {
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((pos) async {
      String address = await getAddressText(pos);
      setState(() {
        currPosition = pos;
        currAddress = address;
        is_currposition_available = true;
      });
    });
  }

  initPositionStream() {
    GeolocatorPlatform.instance
        .getPositionStream(
            locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.best, distanceFilter: 1))
        .listen((pos) async {
      String address = await getAddressText(pos);
      setState(() {
        currPosition = pos;
        currAddress = address;
        is_currposition_available = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: size.height * 0.4,
            child: getMaps(),
          ),
          Column(
            children: [
              Container(
                width: size.width,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                          offset: Offset(0, -2))
                    ],
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(10))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Good " + greeting() + ", ",
                      style: TextStyle(
                        fontSize: 20,
                        color: oxfordBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          is_currposition_available ? "You are near " : " ",
                          style: TextStyle(
                            color: graniteGray,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(is_currposition_available ? currAddress : " ",
                            style: TextStyle(color: celticBlue)),
                      ],
                    ),
                    SizedBox(height: 24),
                    Divider(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Battery Status",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: size.width * 0.7,
                              child: Text(
                                  "A 1-hour record typically consumes 30% battery"),
                            ),
                            Row(
                              children: [
                                Icon(getBatteryIcon(is_battery_available
                                    ? battery_level
                                    : 100)),
                                Text(is_battery_available
                                    ? "${battery_level}%"
                                    : "null"),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 18),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Read Usage Guide",
                    style: TextStyle(
                        color: celticBlue, fontWeight: FontWeight.w500),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(celticBlue),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Recording()));
                        },
                        child: Center(
                          child: Container(
                            width: size.width * 0.4,
                            height: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "New Capture",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  getBatteryIcon(int lev) {
    print(lev);
    if (lev < 30) {
      return Icons.battery_2_bar;
    } else if (lev < 50) {
      return Icons.battery_3_bar;
    } else if (lev < 80) {
      return Icons.battery_4_bar;
    } else {
      return Icons.battery_full;
    }
  }

  String greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Morning';
    }
    if (hour < 17) {
      return 'Afternoon';
    }
    return 'Evening';
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
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
            onMapCreated: (GoogleMapController controller) {
              print("Maps Controller Created!!!!!!!!!!!!!!!");
              if (!_controller.isCompleted) {
                _controller.complete(controller);
                mapsController = controller;
              }
            },
          )
        : Center(child: CircularProgressIndicator());
  }
}
