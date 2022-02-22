import 'dart:convert';

import 'package:http/http.dart';

import '../model/ImageItem.dart';
import '../model/ResponseEntity.dart';
import '../model/mobile_info.dart';

class BusinessError implements Exception {
  final String? message;

  BusinessError(this.message);
}

class AirControllerClient {
  final String _domain;

  AirControllerClient({required String domain}) : _domain = domain;

  Future<List<ImageItem>> getAllImages() async {
    var uri = Uri.parse("${_domain}/image/all");
    Response response = await post(
        uri,
        headers: { "Content-Type": "application/json"},
        body: json.encode({})
    );

    if (response.statusCode == 200) {
        var body = response.body;

        final map = jsonDecode(body);
        final httpResponseEntity = ResponseEntity.fromJson(map);

        if (httpResponseEntity.isSuccessful()) {
          final data = httpResponseEntity.data as List<dynamic>;

          final images = data.map((e) => ImageItem.fromJson(e as Map<String, dynamic>)).toList();
          return images;
        } else {
          throw BusinessError(httpResponseEntity.msg == null
              ? "Unknown error"
              : httpResponseEntity.msg);
        }
      } else {
        throw BusinessError(response.reasonPhrase != null
            ? response.reasonPhrase!
            : "Unknown error");
      }
  }

  Future<MobileInfo> getMobileInfo() async {
    var uri = Uri.parse("${_domain}/common/mobileInfo");
    Response response = await post(
        uri,
        headers: { "Content-Type": "application/json"},
        body: json.encode({})
    );

    if (response.statusCode == 200) {
      var body = response.body;

      final map = jsonDecode(body);
      final httpResponseEntity = ResponseEntity.fromJson(map);

      if (httpResponseEntity.isSuccessful()) {
        final map = httpResponseEntity.data as Map<String, dynamic>;

        final mobileInfo = MobileInfo.fromJson(map);
        return mobileInfo;
      } else {
        throw BusinessError(httpResponseEntity.msg == null
            ? "Unknown error"
            : httpResponseEntity.msg);
      }
    } else {
      throw BusinessError(response.reasonPhrase != null
          ? response.reasonPhrase!
          : "Unknown error");
    }
  }
}