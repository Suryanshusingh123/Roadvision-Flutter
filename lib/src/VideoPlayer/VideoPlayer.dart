import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:aws_common/vm.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:roadvisionflutter/utils/config.dart';
import 'package:video_player/video_player.dart';

import '../../components/toast_messages.dart';
import '../../utils/helpers.dart';
import '../showRecordedVideos/videoFunctions.dart';

class VideoPlayerLocal extends StatefulWidget {
  final videoPath;
  final keys;
  final index;
  const VideoPlayerLocal(
      {super.key,
      required this.videoPath,
      required this.keys,
      required this.index});

  @override
  _VideoPlayerLocalState createState() => _VideoPlayerLocalState();
}

class _VideoPlayerLocalState extends State<VideoPlayerLocal> {
  late VideoPlayerController _controller;
  bool videoControllerReady = false;
  bool playerState = false;
  var videoFunctions;
  var box;
  var uploadProgress = "0.0";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    initBox();
    _controller = VideoPlayerController.file(File(this.widget.videoPath))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {
          videoControllerReady = true;
          videoFunctions = VideoFunctions();
        });
      });
  }

  initBox() async {
    setState(() {
      box = Hive.box(config.hiveBoxName);
    });
    print("BOX DETAILS");
    print(box);
  }

  @override
  void dispose() {
    _controller.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Recorded Videos")),
      body: Column(
        children: [
          videoControllerReady
              ? Container(
                  height: MediaQuery.of(context).size.height / 2,
                  width: MediaQuery.of(context).size.width,
                  child: VideoPlayer(_controller))
              : Text("Loading Video"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                  onPressed: () {
                    if (playerState) {
                      _controller.pause();
                    } else {
                      _controller.play();
                    }
                    setState(() {
                      playerState = !playerState;
                    });
                  },
                  child: !playerState ? Text("Play") : Text("Pause")),
              ElevatedButton(
                  onPressed: () async {
                    showSnackBar(context, "Upload Started");
                    final awsFile = AWSFilePlatform.fromFile(
                        File(box.get(widget.keys[widget.index])['filePath']));
                    try {
                      final uploadResult = await Amplify.Storage.uploadFile(
                        localFile: awsFile,
                        key: '${widget.keys[widget.index].toString()}/file.mp4',
                        onProgress: (progress) {
                          setState(() {
                            uploadProgress = (progress.fractionCompleted * 100)
                                .toStringAsFixed(2);
                          });
                        },
                      ).result;
                      showSnackBar(context, "Uploading Data File");
                      // showErrorMessage("Started Uploading Data File");
                      Map data = box.get(widget.keys[widget.index]);
                      final dataUploadResult = await Amplify.Storage.uploadData(
                              data: S3DataPayload.string(data.toString()),
                              key:
                                  '${widget.keys[widget.index].toString()}/data.txt')
                          .result;
                      showSnackBar(context, "Files Uploaded Successufully");
                    } on StorageException catch (e) {
                      showSnackBar(
                          context, 'Error uploading file: ${e.message}',
                          isError: true);
                      rethrow;
                    }
                  },
                  child: Text("Upload Video $uploadProgress")),
              ElevatedButton(
                  onPressed: () async {
                    print(widget.keys[widget.index]);
                    var fileDelete = await deleteObj(widget.keys[widget.index]);
                    // var fileDelete = await videoFunctions.deleteVideo(
                    //     box.get(widget.keys[widget.index])['id']);
                    if (fileDelete) {
                      box.delete(widget.keys[widget.index]);
                      // TODO: Confirmation Needed!
                      Navigator.of(context).pop();
                      print("File Deleted");
                    } else {
                      print("File Not Deleted");
                    }
                  },
                  child: Text("Delete Video"))
            ],
          )
        ],
      ),
    );
  }
}
