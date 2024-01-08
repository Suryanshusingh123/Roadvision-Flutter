import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:load/load.dart';
import 'package:roadvisionflutter/components/toast_messages.dart';
import 'package:roadvisionflutter/services/backend_service.dart';
import 'package:roadvisionflutter/utils/colors.dart';

import '../auth/register_auth_screen.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController currentPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController newPasswordAgain = TextEditingController();
  String errorText = "Password Strings not matching";
  bool showErrorText = false;
  @override
  void initState() {
    // TODO: implement initState
    newPassword.addListener(() {
      print(newPassword.value.text);
      if (newPasswordAgain.value.toString() != "" &&
          newPassword.value.toString() != "" &&
          newPassword.value != newPasswordAgain.value) {
        setState(() {
          showErrorText = true;
        });
      } else {
        setState(() {
          showErrorText = false;
        });
      }
    });
    newPasswordAgain.addListener(() {
      print(newPasswordAgain.value.text);
      if (newPasswordAgain.value.text != "" &&
          newPassword.value.text.toString() != "" &&
          newPassword.value.text != newPasswordAgain.value.text) {
        setState(() {
          showErrorText = true;
        });
      } else {
        setState(() {
          showErrorText = false;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
          height: 50,
          margin: const EdgeInsets.all(10),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor:
                    newPassword.value.text != newPasswordAgain.value.text
                        ? Colors.grey
                        : Colors.blueAccent),
            onPressed: () async {
              print(newPasswordAgain.value.text);
              print(newPassword.value.text);
              print(currentPassword.value.text);
              if (newPassword.value.text != newPasswordAgain.value.text) {
                return;
              }
              showCustomLoadingWidget(BackendService().returnCustomLoader());
              var resp = await BackendService().resetPasswordApi(
                  currentPassword: currentPassword.value.text,
                  newPassword: newPassword.value.text);
              print(resp);
              hideLoadingDialog();
              if(resp['status'])
                {
                  showLoadingDialog();
                  showSnackBar(context, "Password Reset Successfull");
                }
            },
            child: const Center(
              child: Text('Reset Password'),
            ),
          )),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          height: size.height/2 + 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Reset Password",
                  style: TextStyle(
                    color: oxfordBlue,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              getTextInputField(
                  size.width, currentPassword, 'Current Password'),
              getTextInputField(size.width, newPassword, 'New Password'),
              getTextInputField(
                  size.width, newPasswordAgain, 'Reenter New Password'),
              showErrorText
                  ? Padding(
                      padding: const EdgeInsets.only(left: 25),
                      child: Text(
                        errorText,
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    )
                  : Text(""),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  getTextInputField(width, controller, inputText, {validator: null}) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
        width: width,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 15),
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: const OutlineInputBorder(),
                  hintText: inputText,
                ),
                cursorColor: Colors.black,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                validator: (text) {
                  String password = text ?? "";
                  if (!(password.length > 5) && password.isNotEmpty) {
                    return "Enter valid name of more then 5 characters!";
                  }
                  return null;
                },
                // decoration:  InputDecoration(
                //   hintText:  inputText,
                //   contentPadding: EdgeInsets.zero,
                //   border: InputBorder.none,
                // ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  validatePassword(String password) {
    if (password.length < 6) {
      return "Password length not enough";
    }
  }
}
