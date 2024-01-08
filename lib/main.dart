import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:aws_common/vm.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:load/load.dart';
import 'package:provider/provider.dart';
import 'package:roadvisionflutter/screens/intro/splash_screen.dart';
import 'package:roadvisionflutter/services/backend_service.dart';
import 'package:roadvisionflutter/utils/config.dart';
import 'package:roadvisionflutter/utils/helpers.dart';
import 'package:roadvisionflutter/utils/notifications.dart';
import 'package:wakelock/wakelock.dart';

const amplifyconfig = ''' {
    "UserAgent": "aws-amplify-cli/2.0",
    "Version": "1.0",
    "auth": {
        "plugins": {
            "awsCognitoAuthPlugin": {
                "UserAgent": "aws-amplify-cli/0.1.0",
                "Version": "0.1.0",
                "IdentityManager": {
                    "Default": {}
                },
                "CredentialsProvider": {
                    "CognitoIdentity": {
                        "Default": {
                            "PoolId": "ap-south-1:c9aab3bb-9dfc-4e8f-886b-03a86fcff78f",
                            "Region": "ap-south-1"
                        }
                    }
                },
                "CognitoUserPool": {
                    "Default": {
                        "PoolId": "ap-south-1_JqUd9Rx1i",
                        "AppClientId": "4rfeq8suek2qdmc9r8rjdvcugk",
                        "Region": "ap-south-1"
                    }
                },
                "Auth": {
                    "Default": {
                        "authenticationFlowType": "USER_SRP_AUTH",
                        "socialProviders": [],
                        "usernameAttributes": [],
                        "signupAttributes": [
                            "EMAIL"
                        ],
                        "passwordProtectionSettings": {
                            "passwordPolicyMinLength": 8,
                            "passwordPolicyCharacters": []
                        },
                        "mfaConfiguration": "OFF",
                        "mfaTypes": [
                            "SMS"
                        ],
                        "verificationMechanisms": [
                            "EMAIL"
                        ]
                    }
                },
                "S3TransferUtility": {
                    "Default": {
                        "Bucket": "amplify-roadvision-bucket180503-dev",
                        "Region": "ap-south-1"
                    }
                }
            }
        }
    },
    "storage": {
        "plugins": {
            "awsS3StoragePlugin": {
                "bucket": "amplify-roadvision-bucket180503-dev",
                "region": "ap-south-1",
                "defaultAccessLevel": "guest"
            }
        }
    }
}''';

Future<void> _configureAmplify() async {
  try {
    final auth = AmplifyAuthCognito();
    final storage = AmplifyStorageS3();
    await Amplify.addPlugins([auth, storage]);
    await Amplify.configure(amplifyconfig);
  } on Exception catch (e) {
    safePrint('An error occurred configuring Amplify: $e');
  }
}

mainUpload1(AWSFilePlatform awsFile, String Uid, int index, dynamic keys,
    BuildContext context) async {
  var currData = box.get(keys[index]);
  final uploadResult = await Amplify.Storage.uploadFile(
    localFile: awsFile,
    key: '${Uid.toString()}/file.mp4',
    onProgress: (progress) {
      print((progress.fractionCompleted * 100).toStringAsFixed(2));
      context.read<Progress>().progressUpdate(
          (progress.fractionCompleted * 100).toStringAsFixed(2));
      NotificationService().showProgressNotification(
          id: 0,
          title: '${currData["title"]}',
          body: 'Uploading...',
          maxProgress: 100,
          currentProgress: (progress.fractionCompleted * 100).toInt());
      // NotificationService().showNotification(
      //     title: '${Uid.toString()}/file.mp4 is uploading',
      //     body: (progress.fractionCompleted * 100).toStringAsFixed(2));
      // setState(() {
      //   UIInfoData[keys[index]]["uploadProgress"] =
      //       (progress.fractionCompleted * 100).toStringAsFixed(2);
      // });
    },
  ).result;

  currData['uploaded'] = true;

  if (index != keys.length - 1) {
    box.putAt(keys[index], currData);
  }
  Map data = box.get(keys[index]);

  final dataUploadResult = await Amplify.Storage.uploadData(
          data: S3DataPayload.string(jsonEncode(data)),
          key: '${Uid.toString()}/data.txt')
      .result;
  var backend = BackendService();
  Map<dynamic, dynamic> metaData = {
    'videoTitle': box.get(keys[index])['title'].toString(),
    'fileSize':
        "${(File(box.get(keys[index])['filePath']).lengthSync() / (1024 * 1024)).toStringAsFixed(1)} MB",
  };
  var resp = await backend.videoUploadInfoAdd(
      uid: Uid, metaData: jsonEncode(metaData));
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (defaultTargetPlatform == TargetPlatform.android) {
    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  }
  await Hive.initFlutter();
  await Hive.openBox(config.hiveBoxName);
  await Hive.openBox("storage");
  await _configureAmplify();
  Wakelock.enable();
  config.cameras = await availableCameras();

  NotificationService().initNotification();
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => Progress()),
    ], child: LoadingProvider(themeData: LoadingThemeData(), child: MyApp())),
  );
}

class Progress with ChangeNotifier, DiagnosticableTreeMixin {
  String _progress = '0.0';

  String get progress => _progress;

  void progressUpdate(String progress) {
    _progress = progress;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo 1',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}
