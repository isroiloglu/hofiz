import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:hofiz/core/const/api.dart';
import 'package:hofiz/core/models/page_model.dart';

class PageRepository {
  Dio dio = Dio();

  Future<PageModel> getPage(int id) async {
    log('LOG IS ${'${ApiConst.mainApiUrl}${ApiConst.getPage}/$id'}');
    Response response = await dio.get(
      '${ApiConst.mainApiUrl}${ApiConst.getPage}/$id',
      options: Options(
        headers: {
          "Content-Type": "application/json",
        },
        followRedirects: false,
        validateStatus: (status) {
          return status! < 500;
        },
      ),
    );
    log('STATUS CODE IS ${response.statusCode}');
    log('RESPONSE IS ${response.data}');
    if (response.statusCode == 200) {
      var model = PageModel.fromJson(response.data);
      return model;
    } else {
      throw Exception(response.data["data"]["error"]);
    }
  }
}
