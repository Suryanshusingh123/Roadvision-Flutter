import 'package:flutter/material.dart';
import 'package:load/load.dart';
import 'package:roadvisionflutter/components/toast_messages.dart';
import 'package:roadvisionflutter/screens/auth/account_setup_complete.dart';
import 'package:roadvisionflutter/screens/auth/register_auth_screen.dart';
import 'package:roadvisionflutter/services/backend_service.dart';
import 'package:roadvisionflutter/utils/colors.dart';

class SigninAuthScreen extends StatefulWidget {
  const SigninAuthScreen({Key? key}) : super(key: key);

  @override
  State<SigninAuthScreen> createState() => _SigninAuthScreenState();
}

class _SigninAuthScreenState extends State<SigninAuthScreen> {
  bool hidepassword = true;
  bool loading = false;
  TextEditingController mobile = TextEditingController();
  TextEditingController password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).viewPadding.top + 50),
            Text(
              "Log in",
              style: TextStyle(
                color: oxfordBlue,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                color: Color(0xffeeeeee),
              ),
              padding: EdgeInsets.symmetric(horizontal: 15),
              width: size.width,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.email_outlined,
                    size: 20,
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                        controller: mobile,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                            hintText: "Enter Your Email Id",
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                            counterText: ""),
                        keyboardType: TextInputType.emailAddress),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                color: Color(0xffeeeeee),
              ),
              padding: EdgeInsets.symmetric(horizontal: 15),
              width: size.width,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.key,
                    size: 20,
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      controller: password,
                      cursorColor: Colors.black,
                      obscureText: hidepassword,
                      decoration: InputDecoration(
                        hintText: "Enter Password",
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  InkWell(
                    onTap: () {},
                    child: Text(
                      "Forgot?",
                      style: TextStyle(
                        color: celticBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 15),
            Row(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      hidepassword = !hidepassword;
                    });
                  },
                  child: Icon(
                    hidepassword
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: celticBlue,
                    size: 18,
                  ),
                ),
                SizedBox(width: 7),
                Text("Hide Password")
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
                  onTap: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => RegisterAuthScreen()));
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Sign up Instead",
                      style: TextStyle(
                        color: celticBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    if (mobile.text.isEmpty) {
                      showSnackBar(context, "Phone number cannot be empty",
                          isError: true);
                      // showErrorMessage("Phone number cannot be empty");
                    } else if (mobile.text.length < 10) {
                      showSnackBar(context, "Phone number has invalid format");
                      // showErrorMessage("Phone number has invalid format");
                    } else if (password.text.isEmpty) {
                      showSnackBar(context, "Password cannot be empty");
                      // showErrorMessage("Password cannot be empty");
                    } else {
                      var backend = BackendService();
                      showCustomLoadingWidget(backend.returnCustomLoader());
                      var resp = await backend.login(
                        phone: mobile.text,
                        password: password.text,
                      );
                      hideLoadingDialog();
                      if (resp == true) {
                        showSnackBar(context, "Login Successful");
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) =>
                                const AccountSetupCompleteScreen()));
                      } else {
                        showSnackBar(context, "Incorrect Login Details",
                            isError: true);
                      }
                    }
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 41, vertical: 17.5),
                    color: celticBlue,
                    child: Text(
                      "Log in",
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
    );
  }
}
