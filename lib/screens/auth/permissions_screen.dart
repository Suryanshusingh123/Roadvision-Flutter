import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:roadvisionflutter/screens/home/bottomBarScreen.dart';
import 'package:roadvisionflutter/utils/colors.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({Key? key}) : super(key: key);

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool locationStatus = false;
  bool cameraStatus = false;
  bool storageStatus = false;
  bool showStorage = true;
  int sdkVersion = 10;
  DeviceInfoPlugin plugin = DeviceInfoPlugin();
  late AndroidDeviceInfo android;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPermissionStatus();
    plugin.androidInfo.then((info) {
      android = info;
      if (android.version.sdkInt >= 10) {
        sdkVersion = android.version.sdkInt;
        showStorage = false;
        storageStatus = true;
        checkStatus();
      }
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  getPermissionStatus() async {
    var tempLocationStatus = await Permission.location.isGranted;
    var tempCameraStatus = await Permission.camera.isGranted;
    var tempStorageStatus =
        sdkVersion > 10 ? true : await Permission.storage.isGranted;
    if (mounted) {
      setState(() {
        locationStatus = tempLocationStatus;
        cameraStatus = tempCameraStatus;
        storageStatus = tempStorageStatus;
      });
      if (checkStatus()) {
        pushScreen(context);
      }
    }
  }

  checkStatus() {
    if (locationStatus &&
        cameraStatus &&
        (sdkVersion > 10 ? true : storageStatus)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).viewPadding.top + 80,
            decoration: BoxDecoration(color: piggyPink),
            padding: EdgeInsets.symmetric(vertical: 16.5),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.gpp_maybe_outlined,
                    color: bloodOrange,
                    size: 18,
                  ),
                  SizedBox(width: 5),
                  Text(
                    "Attention required",
                    style: TextStyle(
                        color: bloodOrange, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  Text(
                    "Enable permissions to start capturing road imagery",
                    style: TextStyle(
                      color: oxfordBlue,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 40),
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                            color: platinum.withOpacity(0.9),
                            shape: BoxShape.circle),
                        child: Center(
                          child: Icon(
                            Icons.location_searching_rounded,
                            color: oxfordBlue,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Location Permission",
                            style: TextStyle(
                              color: oxfordBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            "To use GPS",
                            style: TextStyle(
                              color: graniteGray,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      )),
                      InkWell(
                        onTap: () async {
                          if (!locationStatus) {
                            var response = await Permission.location.request();
                            setState(() {
                              locationStatus = response.isGranted;
                            });
                          }
                          if (checkStatus()) {
                            pushScreen(context);
                          }
                        },
                        child: !locationStatus
                            ? Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 13,
                                  vertical: 7.5,
                                ),
                                decoration: BoxDecoration(
                                    color: platinum,
                                    borderRadius: BorderRadius.circular(100)),
                                child: Text(
                                  "Enable",
                                  style: TextStyle(
                                    color: oxfordBlue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.check_circle_outline_rounded,
                                color: Colors.lightGreen,
                              ),
                      ),
                    ],
                  ),
                  SizedBox(height: 25),
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                            color: platinum.withOpacity(0.9),
                            shape: BoxShape.circle),
                        child: Center(
                          child: Icon(
                            Icons.camera_alt_outlined,
                            color: oxfordBlue,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Camera Permission",
                            style: TextStyle(
                              color: oxfordBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            "To record video",
                            style: TextStyle(
                              color: graniteGray,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      )),
                      InkWell(
                        onTap: () async {
                          if (!cameraStatus) {
                            var response = await Permission.camera.request();
                            setState(() {
                              cameraStatus = response.isGranted;
                            });
                          }
                          if (checkStatus()) {
                            pushScreen(context);
                          }
                        },
                        child: !cameraStatus
                            ? Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 13,
                                  vertical: 7.5,
                                ),
                                decoration: BoxDecoration(
                                    color: platinum,
                                    borderRadius: BorderRadius.circular(100)),
                                child: Text(
                                  "Enable",
                                  style: TextStyle(
                                    color: oxfordBlue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : const Icon(Icons.check_circle_outline_rounded,
                                color: Colors.lightGreen),
                      ),
                    ],
                  ),
                  SizedBox(height: 25),
                  showStorage
                      ? Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                  color: platinum.withOpacity(0.9),
                                  shape: BoxShape.circle),
                              child: Center(
                                child: Icon(
                                  Icons.folder_outlined,
                                  color: oxfordBlue,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Storage Permission",
                                  style: TextStyle(
                                    color: oxfordBlue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  "To store recordings",
                                  style: TextStyle(
                                    color: graniteGray,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            )),
                            InkWell(
                              onTap: () async {
                                if (!storageStatus) {
                                  var response =
                                      await Permission.storage.request();
                                  setState(() {
                                    storageStatus = response.isGranted;
                                  });
                                }
                                if (checkStatus()) {
                                  pushScreen(context);
                                }
                              },
                              child: !storageStatus
                                  ? Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 13,
                                        vertical: 7.5,
                                      ),
                                      decoration: BoxDecoration(
                                          color: platinum,
                                          borderRadius:
                                              BorderRadius.circular(100)),
                                      child: Text(
                                        "Enable",
                                        style: TextStyle(
                                          color: oxfordBlue,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.check_circle_outline_rounded,
                                      color: Colors.lightGreen,
                                    ),
                            ),
                          ],
                        )
                      : Text(" "),
                  SizedBox(height: 25),
                  SizedBox(
                    height: 1,
                    width: size.width,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: -25,
                          top: 0,
                          child: Container(
                            width: size.width * 1.2,
                            height: 1,
                            color: platinum,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    child: Row(
                      children: [
                        Text("You can also enable permissions from "),
                        InkWell(
                            onTap: () {
                              print("Tapped");
                            },
                            child: InkWell(
                              onTap: () async {
                                await openAppSettings();
                              },
                              child: Text(
                                "App settings",
                                style: TextStyle(
                                  color: celticBlue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ))
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  RichText(
                    text: TextSpan(
                      text:
                          "Your data is used according to RoadVision AI and Indika AI’s privacy policy.",
                      style: TextStyle(
                        color: graniteGray,
                        fontSize: 14,
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Learn More",
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        height: 1.2,
                        color: celticBlue,
                        fontWeight: FontWeight.w600),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void pushScreen(BuildContext context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const BottomBarScreen(screenIndex: 0)));
  }
}
