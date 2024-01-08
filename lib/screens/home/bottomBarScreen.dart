import 'package:flutter/material.dart';
import 'package:roadvisionflutter/screens/profile/profile_settings.dart';
import 'package:roadvisionflutter/screens/recording/pre_recording.dart';
import 'package:roadvisionflutter/src/showRecordedVideos/ListRecordedVideos.dart';

class BottomBarScreen extends StatefulWidget {
  const BottomBarScreen({Key? key, required this.screenIndex})
      : super(key: key);
  final int screenIndex;
  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> widget_list = [
    PreRecordingScreen(),
    const RecordVideoList(),
    const ProfileSettings()
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: widget_list[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex, //New
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.camera),
              label: 'Capture',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_call_outlined),
              label: 'Recordings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
