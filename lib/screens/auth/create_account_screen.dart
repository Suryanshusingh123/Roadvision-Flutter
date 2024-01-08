import 'package:flutter/material.dart';
import 'package:load/load.dart';
import 'package:roadvisionflutter/components/toast_messages.dart';
import 'package:roadvisionflutter/screens/auth/account_setup_complete.dart';
import 'package:roadvisionflutter/screens/auth/signin_auth_screen.dart';
import 'package:roadvisionflutter/services/backend_service.dart';
import 'package:roadvisionflutter/utils/colors.dart';
import 'package:roadvisionflutter/utils/helpers.dart';

class CreateAccountScreen extends StatefulWidget {
  final String phone;
  const CreateAccountScreen({Key? key, required this.phone}) : super(key: key);

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  TextEditingController mobile = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController invitation = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController password = TextEditingController();
  bool hidepassword = true;
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mobile.text = widget.phone;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SizedBox(
        height: size.height,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Container(
              height: size.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).viewPadding.top + 50),
                  Text(
                    "Create an account",
                    style: TextStyle(
                      color: oxfordBlue,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 40),
                  Container(
                    decoration: BoxDecoration(
                      color: platinum,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    width: size.width,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 20,
                          color: graniteGray,
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: TextField(
                            controller: mobile,
                            enabled: false,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              hintText: "Mobile number",
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(
                          Icons.verified_user_outlined,
                          size: 16,
                          color: Colors.green,
                        ),
                        Text(
                          " Verified",
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: platinum,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    width: size.width,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 20,
                          color: graniteGray,
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: TextField(
                            controller: email,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              hintText: "Enter your email address",
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: platinum,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    width: size.width,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.admin_panel_settings_outlined,
                          size: 20,
                          color: graniteGray,
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: TextField(
                            controller: invitation,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              hintText: "Enter your Unique Invitation Code",
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: graniteGray,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: platinum,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    width: size.width,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_box_outlined,
                          size: 20,
                          color: graniteGray,
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: TextField(
                            controller: name,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              hintText: "Enter your name",
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: platinum,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    width: size.width,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.key_outlined,
                          size: 20,
                          color: graniteGray,
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: TextField(
                            controller: password,
                            cursorColor: Colors.black,
                            obscureText: hidepassword,
                            decoration: InputDecoration(
                              hintText: "Set a password",
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: graniteGray,
                        ),
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
                  loading ? showLoader() : Text(" "),
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
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => SigninAuthScreen()));
                        },
                        child: Text(
                          "Log in Instead",
                          style: TextStyle(
                            color: celticBlue,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          if (email.text.isEmpty) {
                            showSnackBar(context, "Email Cannot be empty",
                                isError: true);
                          } else if (invitation.text.isEmpty) {
                            showSnackBar(
                                context, "Invitation Code cannot be empty",
                                isError: true);
                          } else if (name.text.isEmpty) {
                            showSnackBar(context, "Name cannot be empty",
                                isError: true);
                          } else if (password.text.isEmpty) {
                            showSnackBar(context, "Password cannot be empty",
                                isError: true);
                          } else {
                            // setState(() {
                            //   loading = true;
                            // });
                            var backend = BackendService();
                            showCustomLoadingWidget(
                                backend.returnCustomLoader());
                            var resp = await backend.signup(
                                email: email.text,
                                password: password.text,
                                verificationCode: invitation.text,
                                name: name.text,
                                phone: mobile.text);
                            // setState(() {
                            //   loading = false;
                            // });
                            hideLoadingDialog();
                            if (resp == true) {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AccountSetupCompleteScreen()));
                            } else {
                              showSnackBar(context, "Couldn't Complete SignUp",
                                  isError: true);
                            }
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 41, vertical: 17.5),
                          color: celticBlue,
                          child: Text(
                            "Create",
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
        ),
      ),
    );
  }
}
