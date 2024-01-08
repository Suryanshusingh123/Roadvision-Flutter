import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:roadvisionflutter/screens/auth/permissions_screen.dart';
import 'package:roadvisionflutter/screens/home/bottomBarScreen.dart';
import 'package:roadvisionflutter/services/backend_service.dart';
import 'package:roadvisionflutter/utils/colors.dart';

class AccountSetupCompleteScreen extends StatefulWidget {
  const AccountSetupCompleteScreen({Key? key}) : super(key: key);

  @override
  State<AccountSetupCompleteScreen> createState() =>
      _AccountSetupCompleteScreenState();
}

class _AccountSetupCompleteScreenState
    extends State<AccountSetupCompleteScreen> {
  var userName = "";
  var backendService = BackendService();
  var box = Hive.box("storage");
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
            decoration: BoxDecoration(color: azureishWhite),
            padding: EdgeInsets.symmetric(vertical: 16.5),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified_outlined,
                    color: bangladeshGreen,
                    size: 18,
                  ),
                  SizedBox(width: 5),
                  Text(
                    "Sign up complete",
                    style: TextStyle(
                        color: bangladeshGreen, fontWeight: FontWeight.w600),
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
                  SizedBox(height: 70),
                  Text(
                    "Welcome to RoadVision AI, ${box.get("userName").trim()}.",
                    style: TextStyle(
                      color: oxfordBlue,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                  text:
                                      "You can now record road conditions and distresses using your smartphone camera. It is recommended that you read the "),
                              TextSpan(
                                text: "User Guide",
                                style: TextStyle(
                                  color: oxfordBlue,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(
                                  text:
                                      " before recording any road condition."),
                            ],
                            style: TextStyle(
                              color: graniteGray,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(child: SizedBox()),
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
                  SizedBox(height: 15),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () async {
                          var tempLocationStatus =
                              await Permission.location.isGranted;
                          var tempCameraStatus =
                              await Permission.camera.isGranted;
                          var tempStorageStatus =
                              await Permission.storage.isGranted;

                          if (tempStorageStatus &&
                              tempCameraStatus &&
                              tempLocationStatus) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => BottomBarScreen(
                                      screenIndex: 0,
                                    )));
                          } else {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => PermissionScreen()));
                          }
                        },
                        child: Text(
                          "Go to app",
                          style: TextStyle(
                            color: celticBlue,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {},
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 31, vertical: 17.5),
                          color: celticBlue,
                          child: Text(
                            "Open User Guide",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
