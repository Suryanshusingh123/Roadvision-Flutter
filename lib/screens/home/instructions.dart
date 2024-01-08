import 'package:flutter/material.dart';

import '../../utils/colors.dart';

class Instructions extends StatelessWidget {
  const Instructions({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
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
          SizedBox(height: 8),
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
          SizedBox(height: 24),
          Container(
            color: bangladeshGreen.withOpacity(0.1),
            padding: EdgeInsets.symmetric(horizontal: 17, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.traffic_outlined,
                  color: bangladeshGreen,
                ),
                SizedBox(width: 9),
                Flexible(
                  child: Text(
                    "Wear your seatbelt and follow traffic rules.",
                    style: TextStyle(
                        color: bangladeshGreen, fontWeight: FontWeight.w500),
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 18),
        ],
      ),
    );
  }
}
