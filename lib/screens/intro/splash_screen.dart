import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:roadvisionflutter/screens/auth/permissions_screen.dart';
import 'package:roadvisionflutter/screens/intro/intro_screen.dart';
import 'package:roadvisionflutter/services/backend_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 1), () async {
      var box = Hive.box("storage");
      if (!box.get("authKey").toString().isEmpty) {
        var backend = BackendService();
        var resp = await backend.userCheck();
        try {
          if (resp) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const PermissionScreen()));
          } else {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const IntroScreen()));
          }
        } catch (e) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const IntroScreen()));
        }
      } else {
        print("Reached HERE");
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const IntroScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          "assets/images/splash.png",
          fit: BoxFit.fitWidth,
          width: size.width * 0.7,
        ),
      ),
    );
  }
}
