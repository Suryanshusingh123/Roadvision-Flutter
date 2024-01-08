import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class VideoFunctions {
  Future<String> getPresignedUrl(key, {bool notVideoFile = false}) async {
    String fileKey = "$key/video.mp4";
    if (notVideoFile) {
      fileKey = key;
    }
    var response = await http.get(Uri.parse(
        "https://ugkqxgqyfk5cxmhacyi2ltw5he0hxpqw.lambda-url.ap-south-1.on.aws?fileKey=$fileKey"));
    return response.body;
  }

  Future<http.Response> startVideoUpload(path, uploadUri) async {
    File file = File(path);
    List<int> imageData = file.readAsBytesSync();
    await file.readAsBytes();
    print("file reading Done");
    print((file.lengthSync() / (1024 * 1024)).toString() + "MB");
    var response = await http.put(uploadUri, body: imageData, headers: {
      "Content-Type": "octet-stream",
      "Content-Disposition": 'attachment; filename="resource"',
      "Content-Encoding": "identity",
      "Content-Length": file.lengthSync().toString()
    });
    print("received response");
    print(response);
    if (response.statusCode == 201 || response.statusCode == 200) {
      print('submit video response: ' + response.toString());
      return response;
    } else {
      throw Exception('Failed to post story');
    }
  }

  Future<bool> deleteVideo(path) async {
    await File(path).delete();
    return !await File(path).exists();
  }

  Future<void> uploadJsonData(key, data) async {
    String uploadUrl =
        await getPresignedUrl(key + "/details.data", notVideoFile: true);
    Directory directory = await getApplicationDocumentsDirectory();
    File dataFile = await File(directory.path + '/details.data')
        .writeAsString(data.toString());
    print(directory.path + '/details.data');
    await startVideoUpload(dataFile.path, Uri.parse(uploadUrl));
  }

  // Future<void> chunkedFileUpload(path) async {
  //   print("SATRTED!!!");
  //   const _chunkSize = 5 * 1024 * 1024;
  //   final url = await getPresignedUrl("test.mp4", notVideoFile: false);
  //   final dio = Dio(BaseOptions(baseUrl: url));
  //   //final uploader = ChunkedUploader(dio);
  //   final response = await uploader.uploadUsingFilePath(
  //     filePath: path!,
  //     maxChunkSize: _chunkSize,
  //     path: '/file',
  //     onUploadProgress: (progress) => print(progress),
  //     fileName: 'test.mp4',
  //   );
  //   print("UPLOAD COMPLETE!!");
  // }
}
