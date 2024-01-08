import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:roadvisionflutter/screens/home/bottomBarScreen.dart';
import 'package:roadvisionflutter/screens/videoPlayer/videoPlayer.dart';
import 'package:roadvisionflutter/utils/config.dart';
import 'package:roadvisionflutter/utils/helpers.dart';

import '../../utils/colors.dart';

class RecordingComplete extends StatefulWidget {
  const RecordingComplete({
    Key? key,
    required this.summary,
  }) : super(key: key);
  final Map<String, dynamic> summary;
  @override
  State<RecordingComplete> createState() => _RecordingCompleteState();
}

class _RecordingCompleteState extends State<RecordingComplete> {
  final Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController mapsController;
  bool isProcessing = true;
  @override
  void initState() {
    super.initState();
    // ignore: avoid_print
    print("summary");
    // ignore: avoid_print
    print(widget.summary);
    setState(() {
      isProcessing = false;
    });
  }

  getMapsWithRoute() {
    // ignore: non_constant_identifier_names
    Position initial_pos = widget.summary['initial_position'];
    Map<MarkerId, Marker> markers = widget.summary['markers'];
    // ignore: no_leading_underscores_for_local_identifiers
    Set<Polyline> _polylines = widget.summary['_polylines'];
    return GoogleMap(
      zoomControlsEnabled: false,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      compassEnabled: true,
      initialCameraPosition: CameraPosition(
        target: LatLng(initial_pos.latitude, initial_pos.longitude),
        zoom: 14,
      ),
      markers: Set<Marker>.of(markers.values),
      polylines: _polylines,
      onMapCreated: (GoogleMapController controller) {
        if (!_controller.isCompleted) {
          _controller.complete(controller);
          mapsController = controller;
        }
      },
    );
  }

  processPositions() {
    List<Position?> posList = widget.summary['start_end_positions'];
    return Column(
      children: [
        ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: posList.length,
            itemBuilder: (context, i) {
              if (i == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.fiber_manual_record,
                          size: 10,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text("Starting Point",
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0),
                      child: futureBuilderForPlaceAddress(posList[i]),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                  ],
                );
              } else if (i == (posList.length - 1)) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.square,
                          size: 10,
                          color: celticBlue,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text(
                            "Ending Point",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0),
                      child: futureBuilderForPlaceAddress(posList[i]),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                  ],
                );
              } else if (i % 2 == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.fiber_manual_record,
                          size: 10,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text("Resumed",
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0),
                      child: futureBuilderForPlaceAddress(posList[i]),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                  ],
                );
              } else if (i % 2 == 1) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.fiber_manual_record,
                          size: 10,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text("Paused",
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0),
                      child: futureBuilderForPlaceAddress(posList[i]),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                  ],
                );
              }
            })
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    DateTime now = widget.summary['starting_time'];
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: size.height * 0.4,
            child: InkWell(
              child: getMapsWithRoute(),
            ),
          ),
          Container(
            height: size.height * 0.5,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, -2))
                ],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10))),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ImageIcon(
                        const AssetImage('assets/icons/verified.png'),
                        color: bangladeshGreen,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Capture Complete",
                        style: TextStyle(
                          fontSize: 20,
                          color: bangladeshGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      isProcessing
                          ? const SizedBox(
                              height: 15,
                              width: 15,
                              child: CircularProgressIndicator())
                          : const Text(" "),
                    ],
                  ),
                  const SizedBox(height: 8),
                  processPositions(),
                  const Divider(),
                  getDetailsTextWidget(
                      "Starting Time",
                      ("${now.hour}:${now.minute}:${now.second}"),
                      Icons.watch_later_outlined),
                  getDetailsTextWidget(
                      "Distance Covered",
                      "${widget.summary['distance_covered'].round() / 1000}KM",
                      Icons.directions_car),
                  const Divider(),
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.black),
                    ),
                    onPressed: () {
                      print("open Video");
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => VideoPlayerScreen(
                                path: widget.summary['video_file_path'],
                                title: widget.summary['video_title'],
                                uid: widget.summary['uid'],
                              )));
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.file_copy_outlined),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            widget.summary['video_title'].toString(),
                            overflow: TextOverflow.visible,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward)
                      ],
                    ),
                  ),
                  const Divider(),
                  const SizedBox(
                    height: 5,
                  ),
                  getDetailsTextWidget(
                      "Video Duration",
                      formatedTime(
                          timeInSecond: widget.summary['elapsed_time'].round()),
                      Icons.play_arrow_outlined),
                  getDetailsTextWidget(
                      "File Size",
                      "${(widget.summary['video_file_size'] / (1024 * 1024) as double).round()} MB",
                      Icons.sd_card_outlined),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                color: Colors.white,
                width: size.width * 0.15,
                height: 50,
                child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      side: const BorderSide(width: 2.0, color: Colors.red),
                    ),
                    onPressed: () async {
                      setState(() {
                        isProcessing = true;
                      });
                      // ignore: avoid_print
                      print("delete tapped");
                      Box box = Hive.box(config.hiveBoxName);
                      await deleteObj(box.keys.last);
                      setState(() {
                        isProcessing = false;
                      });
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) =>
                              const BottomBarScreen(screenIndex: 1)));
                    },
                    child: const Icon(Icons.delete_outline)),
              ),
              SizedBox(
                height: 50,
                width: size.width * 0.75,
                child: ElevatedButton(
                  style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      backgroundColor: MaterialStateProperty.all(celticBlue)),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) =>
                            const BottomBarScreen(screenIndex: 1)));
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check),
                      SizedBox(
                        width: 5,
                      ),
                      Text("Save"),
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  futureBuilderForPlaceAddress(Position? pos) {
    var address = getAddressText(pos);
    return FutureBuilder(
        future: address,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Text(
              snapshot.data.toString(),
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }

  getDetailsTextWidget(String title, String valueText, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(100)),
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Icon(
                icon,
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const Spacer(),
          Text(
            valueText,
            style: const TextStyle(fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
