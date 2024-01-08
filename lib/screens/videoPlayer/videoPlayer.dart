import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:info_popup/info_popup.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({Key? key, required this.path, required this.title, required this.uid})
      : super(key: key);
  final String path;
  final String title;
  final String uid;
  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final videoPlayerController;
  late final ChewieController chewieController;
  bool isLoading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.path);
    videoPlayerController = VideoPlayerController.file(File(widget.path));

    videoPlayerController.initialize().then((val) {
      chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay: false,
        looping: true,
      );
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          InfoPopupWidget(
            contentTitle: widget.uid,
            arrowTheme: InfoPopupArrowTheme(
              color: Colors.black,
              arrowDirection: ArrowDirection.up,
            ),
            contentTheme: InfoPopupContentTheme(
              infoContainerBackgroundColor: Colors.black,
              infoTextStyle: TextStyle(color: Colors.white),
              contentPadding: const EdgeInsets.all(8),
              contentBorderRadius: BorderRadius.all(Radius.circular(10)),
              infoTextAlign: TextAlign.center,
            ),
            dismissTriggerBehavior: PopupDismissTriggerBehavior.anyWhere,
            areaBackgroundColor: Colors.transparent,
            indicatorOffset: Offset.zero,
            contentOffset: Offset.zero,
            onControllerCreated: (controller) {
              print('Info Popup Controller Created');
            },
            onAreaPressed: (InfoPopupController controller) {
              print('Area Pressed');
            },
            infoPopupDismissed: () {
              print('Info Popup Dismissed');
            },
            onLayoutMounted: (Size size) {
              print('Info Popup Layout Mounted');
            },
            child: Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 10,)
        ],
      ),
      body: Container(
        child: isLoading
            ? Text("Loading Player")
            : Chewie(
                controller: chewieController,
              ),
      ),
    );
  }
}
