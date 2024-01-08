import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive/hive.dart';
import 'package:roadvisionflutter/services/api_service.dart';

class BackendService {
  static final BackendService _singleton = BackendService._internal();

  factory BackendService() {
    return _singleton;
  }

  BackendService._internal();

  ApiService apiService = ApiService();

  login({required String phone, required String password}) async {
    var resp = await apiService.postApi(url: "/flutterApi/auth/login", body: {
      "email": phone,
      "password": password,
    });
    if (resp != null && resp["status"] == "success") {
      var box = Hive.box("storage");
      box.put("authKey", resp["result"]["token"]);
      box.put("userName", resp["result"]["user_details"]["name"]);
      box.put("userEmail", resp["result"]["user_details"]["email"]);
      apiService.update();
      return true;
    } else {
      return false;
    }
  }

  signup({
    required String email,
    required String password,
    required String verificationCode,
    required String name,
    required String phone,
  }) async {
    var resp = await apiService.postApi(url: "/flutterApi/auth/signup", body: {
      "email": email,
      "password": password,
      "unique_verification_code": verificationCode,
      "name": name,
      "phone_number": phone,
    });
    if (resp != null && resp["status"] == "success") {
      var box = Hive.box("storage");
      box.put("userName", name);
      box.put("userEmail", email);
      return true;
    } else {
      return false;
    }
  }

  userCheck() async {
    var resp = await apiService.getApi(url: "/flutterApi/auth/protected");
    print(resp);
    if (resp != null && resp["status"] == "success") {
      return true;
    } else {
      return false;
    }
  }

  returnCustomLoader() {
    return const SpinKitDoubleBounce(
      color: Colors.white,
      size: 50.0,
    );
  }

  sendOTP({required String phone_number}) async {
    var resp = await apiService.postApi(
        url: "/flutterApi/auth/send_otp",
        body: {"phone_number": "+91$phone_number"});
    if (resp != null &&
        resp["+91$phone_number"]["DeliveryStatus"] == "SUCCESSFUL") {
      return {
        "status": true,
        "reference_id": resp["+91$phone_number"]["reference_id"],
        "destination_number": "+91$phone_number"
      };
    } else {
      return false;
    }
  }
  resetPasswordApi({required String currentPassword,required String newPassword}) async {
    var resp = await apiService.postApi(
        url: "/flutterApi/auth/resetPassword",
        body: {"password": currentPassword,"new_password" : newPassword});
    if (resp != null &&
        resp["result"]["msgCode"] == "passwordCorrect") {
      return {
        "status": true,
        "message": resp['message']
      };
    } else {
      return {
        "status": false,
        "message": resp['message']
      };
    }
  }

  verifyOTP(
      {required String phone_number,
      required String reference_id,
      required String OTP}) async {
    var resp = await apiService.postApi(
        url: "/flutterApi/auth/verify_otp",
        body: {
          "phone_number": "+91$phone_number",
          "reference_id": reference_id,
          "otp": OTP
        });
    if (resp != null && resp["Valid"]) {
      return true;
    } else {
      return false;
    }
  }

  logout() async {
    var box = Hive.box("storage");
    box.delete("authKey");
    apiService.update();
  }

  videoUploadInfoAdd({
    required String uid,
    String metaData = "NA",
  }) async {
    print("Meta Data received");
    print(metaData);
    var resp = await apiService.postApi(
        url: "/flutterApi/info/video_upload",
        body: {
          "uid": uid,
          "meta_data": metaData,
        },
        useToken: true);
    if (resp != null && resp["status"] == "success") {
      return true;
    } else {
      return false;
    }
  }
  checkifvideoUploaded({
    required String uid
  }) async {
    var resp = await apiService.postApi(
        url: "/flutterApi/info/check_if_video_uploaded",
        body: {
          "uid": uid,
        },
        useToken: true);
    if (resp != null && resp["status"] == "success") {
      return resp['result']['isUploaded'];
    } else {
      return false;
    }
  }
}
