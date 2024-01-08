import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:load/load.dart';
import 'package:roadvisionflutter/components/toast_messages.dart';
import 'package:roadvisionflutter/screens/auth/create_account_screen.dart';
import 'package:roadvisionflutter/screens/auth/signin_auth_screen.dart';
import 'package:roadvisionflutter/services/backend_service.dart';
import 'package:roadvisionflutter/utils/colors.dart';

import '../../utils/helpers.dart';

class RegisterAuthScreen extends StatefulWidget {
  const RegisterAuthScreen({Key? key}) : super(key: key);

  @override
  State<RegisterAuthScreen> createState() => _RegisterAuthScreenState();
}

class _RegisterAuthScreenState extends State<RegisterAuthScreen> {
  bool codeSent = false;
  TextEditingController mobile = TextEditingController();
  TextEditingController code = TextEditingController();
  BackendService backendService = BackendService();
  String referenceId = "";
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                color: platinum,
                border:
                    codeSent ? Border.all(color: oxfordBlue, width: 2) : null,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              width: size.width,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    size: 20,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      controller: mobile,
                      enabled: !codeSent,
                      maxLength: 10,
                      cursorColor: Colors.black,
                      decoration: const InputDecoration(
                          hintText: "Enter your mobile number",
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          counterText: ""),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      setState(() {
                        codeSent = false;
                      });
                    },
                    child: Text(
                      "Change",
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
            const SizedBox(height: 15),
            Row(
              crossAxisAlignment: !codeSent
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 20,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: RichText(
                    text: codeSent
                        ? TextSpan(
                            children: [
                              const TextSpan(
                                  text: "A verification code is sent to "),
                              TextSpan(
                                text: "${mobile.text}.",
                                style: TextStyle(
                                  color: oxfordBlue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const TextSpan(text: "\nEnter the code below."),
                            ],
                            style: TextStyle(
                              color: graniteGray,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : TextSpan(
                            children: [
                              const TextSpan(
                                  text: "A verification code will be sent to "),
                              TextSpan(
                                text: "this number.",
                                style: TextStyle(
                                  color: oxfordBlue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            ],
                            style: TextStyle(
                              color: graniteGray,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            if (codeSent) const SizedBox(height: 40),
            if (codeSent)
              Container(
                decoration: BoxDecoration(
                  color: platinum,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                width: size.width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.dialpad,
                      size: 20,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextField(
                        controller: code,
                        maxLength: 6,
                        cursorColor: Colors.black,
                        decoration: const InputDecoration(
                            hintText: "Enter verification code",
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                            counterText: ""),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {},
                      child: Text(
                        "Resend",
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
            const Expanded(child: SizedBox()),
            isLoading ? showLoader() : const Text(" "),
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
            const SizedBox(height: 15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const SigninAuthScreen()));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "Log in Instead",
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
                    if (codeSent == false) {
                      if (mobile.text.isEmpty) {
                        showSnackBar(context, "Phone Number cannot be empty",
                            isError: true);
                      } else if (mobile.text.length < 10) {
                        showSnackBar(context, "Phone number has invalid format",
                            isError: true);
                        //showErrorMessage("Phone number has invalid format");
                      } else {
                        showCustomLoadingWidget(
                            backendService.returnCustomLoader());
                        setState(() {
                          codeSent = true;
                        });
                        var response = await backendService.sendOTP(
                            phone_number: mobile.text);
                        // ignore: avoid_print
                        print(response);
                        if (response["status"]) {
                          setState(() {
                            referenceId = response["reference_id"];
                            codeSent = true;
                          });
                          stopLoading();
                        }
                        Future.delayed(const Duration(seconds: 1), () {
                          showSnackBar(context, "Code Sent Successfully!");
                          hideLoadingDialog();
                        });
                      }
                    } else {
                      if (code.text.isEmpty) {
                        showSnackBar(
                            context, "Verification code cannot be empty");
                        // showErrorMessage("Verification Code cannot be empty");
                      } else if (code.text.length < 6) {
                        showSnackBar(context,
                            "Not enough digits in the verification code");
                        // showErrorMessage("Incorrect Code");
                      } else {
                        showCustomLoadingWidget(
                            backendService.returnCustomLoader());
                        // Future.delayed(Duration(seconds: 1), () {
                        //   hideLoadingDialog();
                        //   showSnackBar(context, "Code Verified");
                        //   Navigator.of(context).push(MaterialPageRoute(
                        //       builder: (context) => CreateAccountScreen(
                        //             phone: mobile.text,
                        //           )));
                        // });
                        startLoading();
                        var response = await backendService.verifyOTP(
                            phone_number: mobile.text,
                            reference_id: referenceId,
                            OTP: code.text);
                        // ignore: avoid_print
                        print(response);
                        if (response) {
                          stopLoading();
                          hideLoadingDialog();
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => CreateAccountScreen(
                                    phone: mobile.text,
                                  )));
                        } else {
                          stopLoading();
                          hideLoadingDialog();
                          // ignore: use_build_context_synchronously
                          showSnackBar(context, "Invalid OTP", isError: true);
                        }
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 41, vertical: 17.5),
                    color: celticBlue,
                    child: Text(
                      codeSent == true ? "Verify OTP" : "Send Code",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void startLoading() {
    setState(() {
      isLoading = true;
    });
  }

  void stopLoading() {
    setState(() {
      isLoading = false;
    });
  }
}
