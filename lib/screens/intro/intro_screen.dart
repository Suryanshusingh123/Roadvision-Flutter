import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:roadvisionflutter/utils/colors.dart';

import '../auth/register_auth_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
          width: size.width,
          height: size.height,
          padding: EdgeInsets.fromLTRB(20, 50, 20, 00),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              celticBlue,
              celticBlue.withAlpha(245),
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Image.asset(
                          "assets/images/splash.png",
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        child: Image.asset(
                          "assets/images/intro.png",
                          height: size.height * 0.4,
                          width: size.width,
                        ),
                      )
                    ],
                  )),
                  Text(
                    "© 2023 Indika AI",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "Capture road condition and\ndistress data right from\nyour smartphone",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        height: 1.35),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/icons/capture.svg",
                        ),
                        SizedBox(width: 6.5),
                        Text(
                          "Capture",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 15),
                        DottedLine(
                          direction: Axis.vertical,
                          lineLength: 15,
                          lineThickness: 1,
                          dashLength: 1.5,
                          dashColor: Colors.white,
                          dashGapLength: 1.5,
                          dashGapColor: Colors.transparent,
                        ),
                        SizedBox(width: 15),
                        SvgPicture.asset(
                          "assets/icons/review.svg",
                        ),
                        SizedBox(width: 6.5),
                        Text(
                          "Review",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 15),
                        DottedLine(
                          direction: Axis.vertical,
                          lineLength: 15,
                          lineThickness: 1.5,
                          dashLength: 1.5,
                          dashColor: Colors.white,
                          dashGapLength: 1.5,
                          dashGapColor: Colors.transparent,
                        ),
                        SizedBox(width: 15),
                        SvgPicture.asset(
                          "assets/icons/upload.svg",
                        ),
                        SizedBox(width: 6.5),
                        Text(
                          "Upload",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => RegisterAuthScreen()));
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(color: Colors.white),
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.transparent,
                          ),
                          Text(
                            "Get Started",
                            style: TextStyle(
                                color: oxfordBlue,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            color: oxfordBlue,
                            weight: 15,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
