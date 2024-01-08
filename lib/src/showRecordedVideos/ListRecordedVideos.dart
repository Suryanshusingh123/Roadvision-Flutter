import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:aws_common/vm.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:roadvisionflutter/main.dart';
import 'package:roadvisionflutter/services/backend_service.dart';
import 'package:roadvisionflutter/utils/config.dart';

import '../../components/toast_messages.dart';
import '../../screens/videoPlayer/videoPlayer.dart';
import '../../utils/colors.dart';
import '../../utils/helpers.dart';

class RecordVideoList extends StatefulWidget {
  const RecordVideoList({super.key});

  @override
  _RecordVideoListState createState() => _RecordVideoListState();
}

class _RecordVideoListState extends State<RecordVideoList> {
  late List<FileSystemEntity> recordedVideos;
  late var box;
  late var keys;
  bool isLoaded = false;
  final dio = Dio();
  bool videoUploading = false;
  String dropDownValue = "time";
  String progress = "50";
  var UIInfoData = {};
  var videoUploadStatus = {};
  checkIfVideosUploaded() async {
    var backendService = BackendService();
    for (var i = 0; i < keys.length; i++) {
      var isVideoUploaded = await backendService.checkifvideoUploaded(
          uid: box.get(keys[i])['uid']);
      print("is uploaded?????");
      print(isVideoUploaded);
      videoUploadStatus[box.get(keys[i])['uid']] = {
        "uploaded": isVideoUploaded
      };
    }
    setState(() {});
  }

  void processUploadQueue() async {
    for (int index = 0; index < keys.length; index++) {
      print("indexssssss:;;; -     $index");
      await uploadFunction(index);
    }
  }

  uploadFunction(int index) async {
    if (checkVideoUploadStatus(box.get(keys[index])['uid'])) {
      print("video Already Uploaded");
      return;
    }
    setState(() {
      UIInfoData[keys[index]] = {"uploading": "true", "uploadProgress": "0.00"};
    });
    showSnackBar(context, "Upload Started");

    try {
      if (index < keys.length) {
        print("Uploading ********");
        String Uid = box.get(keys[index])['uid'];
        print(Uid);
        showSnackBar(context, "Processing Upload");
        final awsFile =
            AWSFilePlatform.fromFile(File(box.get(keys[index])['filePath']));
        // ignore: use_build_context_synchronously
        context.read<Progress>().addListener(() => setState(() {
              UIInfoData[keys[index]]["uploadProgress"] =
                  context.read<Progress>().progress;
            }));
        // ignore: use_build_context_synchronously
        await mainUpload1(awsFile, Uid, index, keys, context);
        // final uploadResult = await Amplify.Storage.uploadFile(
        //   localFile: awsFile,
        //   key: '${Uid.toString()}/file.mp4',
        //   onProgress: (progress) {
        //     setState(() {
        //       UIInfoData[keys[index]]["uploadProgress"] =
        //           (progress.fractionCompleted * 100).toStringAsFixed(2);
        //     });
        //   },
        // ).result;
        // Map data = box.get(keys[index]);
        // final dataUploadResult = await Amplify.Storage.uploadData(
        //         data: S3DataPayload.string(jsonEncode(data)),
        //         key: '${Uid.toString()}/data.txt')
        //     .result;

        setState(() {
          UIInfoData[keys[index]]["uploading"] = "complete";
        });
      }
    } on StorageException catch (e) {
      showSnackBar(context, "Error uploading file: ${e.message}");
      rethrow;
    }
  }

  bool _isUploading = false;

  Future<void> runUploadFunction(int index) async {
    if (await checkConnectivity()) {
      setState(() {
        _isUploading = true;
      });

      try {
        await uploadFunction(index);
        showSnackBar(context, 'Upload Complete');
      } catch (e) {
        showSnackBar(context, 'Error: $e');
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    } else {
      showSnackBar(context, 'No internet connection');
    }
  }

  Future<bool> checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> getListOfRecordedVideos() async {
    box = Hive.box(config.hiveBoxName);
    print(getLocalUserDetails());
    var currentUserDetails = getLocalUserDetails();
    List<String> dbKeys = [];
    // box.keys
    //     .toString()
    //     .replaceAll(new RegExp(r"([() ]+)"), '')
    //     .split(',')
    //     .forEach((key) {
    //   dbKeys.add(key);
    // });
    var filteredKeysList = [];
    for (var key in box.keys) {
      var currData = box.get(key);
      if (currData['userEmail'] == currentUserDetails['userEmail']) {
        filteredKeysList.add(key);
      }
    }
    setState(() {
      keys = filteredKeysList;
    });
    var tempUIData = {};
    for (var i = 0; i < keys.length; i++) {
      videoUploadStatus[box.get(keys[i])['uid']] = {"uploaded": true};
      tempUIData[keys[i]] = {"uploading": "false", "uploadProgress": "0.00"};
    }
    setState(() {
      UIInfoData = tempUIData;
      isLoaded = true;
    });
    // print(box.get('locationDetails'));
  }

  @override
  void initState() {
    super.initState();
    recordedVideos = [];
    getListOfRecordedVideos();
    checkIfVideosUploaded();
  }

  bool checkVideoUploadStatus(String uid) {
    print(videoUploadStatus);
    if (videoUploadStatus == 0) {
      return false;
    }
    return videoUploadStatus[uid]['uploaded'];
  }

  bool selected = false;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SafeArea(
        child: Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: size.width,
          height: size.height,
          padding: const EdgeInsets.fromLTRB(16, 50, 25, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Recordings",
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 28)),
                  selected
                      ? Row(children: [
                          ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  selected = !selected;
                                });
                              },
                              child: Text("Cancel")),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: ElevatedButton(
                                onPressed: () async {
                                  processUploadQueue();
                                },
                                child: Text("Upload")),
                          ),
                        ])
                      : ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selected = !selected;
                            });
                          },
                          child: Text("Select All")),
                ],
              ),
              // DropdownButton(
              //     value: dropDownValue,
              //     items: const [
              //       DropdownMenuItem(
              //         value: "time",
              //         child: Text("Sorted By Time"),
              //       ),
              //       DropdownMenuItem(
              //         value: "duration",
              //         child: Text("Sorted By Duration"),
              //       ),
              //     ],
              //     onChanged: (String? value) {
              //       setState(() {
              //         dropDownValue = value.toString();
              //       });
              //     }),
              Expanded(
                child: Container(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: keys.length,
                    itemBuilder: (context, index) {
                      if (box.get(keys[index]) == null) {
                        return const SizedBox();
                      }
                      return InkWell(
                        splashColor: Colors.amber,
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => VideoPlayerScreen(
                                  path: box.get(keys[index])['filePath'],
                                  title: "Video File",
                                  uid: box.get(keys[index])['uid'])));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: selected
                                  ? Color.fromARGB(91, 107, 178, 237)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(5)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                UIInfoData[keys[index]]["uploading"] == "true"
                                    ? SizedBox(
                                        height: 10,
                                      )
                                    : SizedBox(),
                                UIInfoData[keys[index]]["uploading"] == "true"
                                    ? Container(
                                        height: 25,
                                        color:
                                            Color(0xFF1967D2).withOpacity(0.1),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                                child: Row(
                                              children: [
                                                Container(
                                                  height: 25,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10),
                                                  child: Icon(
                                                    Icons.cloud_upload,
                                                    color: celticBlue,
                                                    size: 15,
                                                  ),
                                                ),
                                              ],
                                            )),
                                            Text(
                                              "Uploading... (${UIInfoData[keys[index]]["uploadProgress"]}%)",
                                              style:
                                                  TextStyle(color: celticBlue),
                                            )
                                          ],
                                        ))
                                    : SizedBox(),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Container(
                                        height: 100,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  flex: 1,
                                                  child: Text(
                                                    box
                                                        .get(keys[index])[
                                                            'title']
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                                // SizedBox(width: 5,),
                                                // InfoPopupWidget(
                                                //   contentTitle: 'Info Popup Details',
                                                //   arrowTheme: InfoPopupArrowTheme(
                                                //     color: Colors.lightBlueAccent,
                                                //     arrowDirection: ArrowDirection.up,
                                                //   ),
                                                //   contentTheme: InfoPopupContentTheme(
                                                //     infoContainerBackgroundColor: Colors.black,
                                                //     infoTextStyle: TextStyle(color: Colors.white),
                                                //     contentPadding: const EdgeInsets.all(8),
                                                //     contentBorderRadius: BorderRadius.all(Radius.circular(10)),
                                                //     infoTextAlign: TextAlign.center,
                                                //   ),
                                                //   dismissTriggerBehavior: PopupDismissTriggerBehavior.anyWhere,
                                                //   areaBackgroundColor: Colors.transparent,
                                                //   indicatorOffset: Offset.zero,
                                                //   contentOffset: Offset.zero,
                                                //   onControllerCreated: (controller) {
                                                //     print('Info Popup Controller Created');
                                                //   },
                                                //   onAreaPressed: (InfoPopupController controller) {
                                                //     print('Area Pressed');
                                                //   },
                                                //   infoPopupDismissed: () {
                                                //     print('Info Popup Dismissed');
                                                //   },
                                                //   onLayoutMounted: (Size size) {
                                                //     print('Info Popup Layout Mounted');
                                                //   },
                                                //   child: Icon(
                                                //     Icons.info_outline,
                                                //     color: Colors.blueAccent,
                                                //     size: 20,
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                            Flexible(
                                              flex: 1,
                                              child: Text(
                                                "${(box.get(keys[index])['createdAt'])} • ${(File(box.get(keys[index])['filePath']).lengthSync() / (1024 * 1024)).toStringAsFixed(1)} MB",
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            ),
                                            Flexible(
                                                flex: 1,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                                0, 0, 5, 0),
                                                        child: SvgPicture.asset(
                                                            "assets/icons/explore.svg")),
                                                    Flexible(
                                                      child: Text(
                                                          '${box.get(keys[index])['startAddress']} - ${box.get(keys[index])['endAddress']}',
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xFF00764B))),
                                                    )
                                                  ],
                                                )),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                        flex: 1,
                                        child: Center(
                                          child: InkWell(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: celticBlue),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              100))),
                                              child: Container(
                                                  width: 65,
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 5),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      SvgPicture.asset(
                                                          "assets/icons/play_circle.svg"),
                                                      Text(secondsToTime(
                                                          box.get(keys[index])[
                                                              'videoLength'])),
                                                    ],
                                                  )),
                                            ),
                                          ),
                                        ))
                                  ],
                                ),
                                UIInfoData[keys[index]]["uploading"] == "false"
                                    ? Container(
                                        height: 50,
                                        color: platinum,
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Expanded(
                                                  child: InkWell(
                                                    child: Column(
                                                      children: const [
                                                        Icon(
                                                            Icons
                                                                .delete_outline,
                                                            color: Colors.red),
                                                        Text(
                                                          "Delete",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 13,
                                                              color:
                                                                  Colors.red),
                                                        )
                                                      ],
                                                    ),
                                                    onTap: () async {
                                                      print(keys[index]);
                                                      var fileDelete =
                                                          await deleteObj(
                                                              keys[index]);
                                                      if (fileDelete) {
                                                        // box.delete(keys[index]);
                                                        // TODO: Confirmation Needed!
                                                        showSnackBar(context,
                                                            "File Deleted");
                                                        // showErrorMessage(
                                                        //     "File Deleted");
                                                        getListOfRecordedVideos();
                                                      } else {
                                                        showSnackBar(context,
                                                            "File Delete Error");
                                                        // showErrorMessage(
                                                        //     "File Delete Error");
                                                      }
                                                    },
                                                  ),
                                                ),
                                                Expanded(
                                                  child: InkWell(
                                                    child: Column(
                                                      children: [
                                                        checkVideoUploadStatus(
                                                                box.get(keys[
                                                                        index])[
                                                                    'uid'])
                                                            ? Icon(
                                                                Icons.check,
                                                                color: Colors
                                                                    .green,
                                                              )
                                                            : Icon(
                                                                Icons
                                                                    .arrow_upward_outlined,
                                                                color:
                                                                    celticBlue),
                                                        Text(
                                                          checkVideoUploadStatus(
                                                                  box.get(keys[
                                                                          index])[
                                                                      'uid'])
                                                              ? "Uploaded"
                                                              : "Upload",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 13,
                                                              color:
                                                                  celticBlue),
                                                        )
                                                      ],
                                                    ),
                                                    onTap: () async {
                                                      if (!_isUploading) {
                                                        await runUploadFunction(
                                                            index);
                                                      }
                                                    },
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    : SizedBox()
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const Divider(
                        height: 1,
                        color: Colors.black,
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }
}
