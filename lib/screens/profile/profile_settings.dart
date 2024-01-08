import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:roadvisionflutter/screens/profile/change_password.dart';
import 'package:roadvisionflutter/screens/profile/pdfScreen.dart';
import 'package:roadvisionflutter/utils/helpers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../utils/config.dart';
import '../intro/intro_screen.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({Key? key}) : super(key: key);

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  Map<dynamic, dynamic> userDetails = getLocalUserDetails();
  late PackageInfo packageInfo;
  String appName = 'App name';
  String packageName = 'package name';
  String version = 'version number';
  String buildNumber = 'build number';
  Future<void> initPackageInfo() async {
    packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      appName = packageInfo.appName;
      packageName = packageInfo.packageName;
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPackageInfo();
  }

  getSettingOption(IconData icon, String text, {action: null}) {
    return TextButton(
        onPressed: () {
          action();
        },
        child: Row(
          children: [
            SizedBox(
              width: 10,
            ),
            Icon(
              icon,
              color: Colors.black,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              text,
              style: TextStyle(color: Colors.black),
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 40,
              ),
              const Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Account',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 40),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/profile_picture.png',
                      height: 80,
                      width: 80,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userDetails['userName'],
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 20),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          userDetails['userEmail'],
                          style: TextStyle(color: Colors.black54),
                        )
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Column(
                children: [
                  getSettingOption(Icons.key, 'Change Password', action: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ChangePassword()));
                  }),
                  getSettingOption(Icons.menu_book_rounded, 'Read Usage Guide',
                      action: () {
                    // Navigator.of(context).push(
                    //     MaterialPageRoute(builder: (context) => PdfViewer()));
                  }),
                  getSettingOption(Icons.info, 'Terms and Agreements',
                      action: () async {
                    const URL = "https://www.roadvision.ai/terms-of-usage";
                    if (await canLaunchUrl(Uri.parse(URL))) {
                      await launchUrl(Uri.parse(URL));
                    } else {
                      print("Cannot Launch Webpage");
                    }
                  }),
                ],
              ),
              const Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Divider(),
              ),
              const Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Logging out will cancel all your active uploads.\nYou will need to restart all cancelled uploads once you log back in.',
                  style: TextStyle(color: Colors.black54, fontSize: 15),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () async {
                    var box = Hive.box("storage");
                    print(config.hiveBoxName);
                    print(box.keys);
                    await box.delete("authkey");
                    await box.delete("userEmail");
                    await box.delete("userName");
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const IntroScreen()));
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.logout,
                        color: Colors.red,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text(
                        'Log out',
                        style: TextStyle(color: Colors.red, fontSize: 18),
                      ),
                      SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(appName + ' ' + version + ' ' + buildNumber))
            ],
          ),
        ),
      ),
    );
  }
}
