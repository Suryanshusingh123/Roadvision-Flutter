import 'package:camera/camera.dart';

class Config {
  String googleMapsAPIKey = "AIzaSyBGFCXOS0At4PAHkpzotnTsyVCe62-8Mlg";
  late List<CameraDescription> cameras;
  String hiveBoxName = 'locationBox';
  double mapsInitialZoom = 14.5;
  String baseUrl =
      'https://srph1a4vpj.execute-api.ap-south-1.amazonaws.com/dev';
}

Config config = Config();
