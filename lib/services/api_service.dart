import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:roadvisionflutter/utils/config.dart';

class ApiService {
  final _baseUrl = config.baseUrl;

  Dio dio = Dio();
  late Box box;
  bool isLogin = false;

  ApiService() {
    update();
  }

  update() {
    dio.options.headers['content-Type'] = 'application/x-www-form-urlencoded';
    box = Hive.box("storage");
    if (box.containsKey("authKey")) {
      dio.options.headers["token"] = "${box.get("authKey")}";
      isLogin = true;
    } else {
      isLogin = false;
    }
  }

  getApi({required String url}) async {
    try {
      var box = Hive.box("storage");
      dio.options.headers["token"] = "${box.get("authKey")}";
      Response response = await dio.get(_baseUrl + url);
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        print('Dio error!');
        print('STATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}');
        print('HEADERS: ${e.response?.headers}');
      } else {
        print('Error sending request!');
        print(e.message);
      }
    } catch (e) {
      print(e);
    }
  }

  postApi({required String url, required body, bool useToken = false}) async {
    try {
      print(url);
      print(body);
      if (useToken) {
        dio.options.headers["token"] = "${box.get("authKey")}";
      }
      Response response = await dio.post(_baseUrl + url, data: body);
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        print('Dio error!');
        print('STATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}');
        print('HEADERS: ${e.response?.headers}');
      } else {
        print('Error sending request!');
        print(e.message);
      }
    } catch (e) {
      print(e);
    }
  }

  putApi({required String url, required body}) async {
    try {
      Response response = await dio.put(_baseUrl + url, data: body);
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        print('Dio error!');
        print('STATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}');
        print('HEADERS: ${e.response?.headers}');
      } else {
        print('Error sending request!');
        print(e.message);
      }
    } catch (e) {
      print(e);
    }
  }

  deleteApi({required String url, required body}) async {
    try {
      Response response = await dio.delete(_baseUrl + url);
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        print('Dio error!');
        print('STATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}');
        print('HEADERS: ${e.response?.headers}');
      } else {
        print('Error sending request!');
        print(e.message);
      }
    } catch (e) {
      print(e);
    }
  }
}
