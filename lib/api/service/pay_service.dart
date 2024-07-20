import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:geideapay/api/response/order_api_response.dart';
import 'package:geideapay/api/service/base_service.dart';
import 'package:geideapay/api/service/contracts/pay_service_contract.dart';
import 'package:geideapay/common/exceptions.dart';
import 'package:geideapay/common/my_strings.dart';
import 'package:geideapay/common/extensions.dart';
import 'package:http/http.dart' as http;
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../response/request_pay_api_response.dart';

class PayService with BaseApiService implements PayServiceContract {
  @override
  Future<OrderApiResponse> directPay(Map<String, Object?>? fields,
      String publicKey, String apiPassword, String baseUrl) async {
    var url = '$baseUrl/pgw/api/v2/direct/pay';
    return genResponse(url, fields, publicKey, apiPassword);
  }

  @override
  Future<OrderApiResponse> payWithToken(Map<String, Object?>? fields,
      String publicKey, String apiPassword, String baseUrl) async {
    var url = '$baseUrl/pgw/api/v1/direct/pay/token';
    return genResponse(url, fields, publicKey, apiPassword);
  }

  @override
  Future<OrderApiResponse> cancel(Map<String, Object?>? fields,
      String publicKey, String apiPassword, String baseUrl) async {
    var url = '$baseUrl/pgw/api/v1/direct/cancel';
    return genResponse(url, fields, publicKey, apiPassword);
  }

  @override
  Future<OrderApiResponse> capture(Map<String, Object?>? fields,
      String publicKey, String apiPassword, String baseUrl) async {
    var url = '$baseUrl/pgw/api/v1/direct/capture';
    return genResponse(url, fields, publicKey, apiPassword);
  }

  @override
  Future<OrderApiResponse> refund(Map<String, Object?>? fields,
      String publicKey, String apiPassword, String baseUrl) async {
    var url = '$baseUrl/pgw/api/v1/direct/refund';
    return genResponse(url, fields, publicKey, apiPassword);
  }

  @override
  Future<OrderApiResponse> voidOperation(Map<String, Object?>? fields,
      String publicKey, String apiPassword, String baseUrl) async {
    var url = '$baseUrl/pgw/api/v1/direct/refund';
    return genResponse(url, fields, publicKey, apiPassword);
  }

  @override
  Future<RequestPayApiResponse> requestToPay(Map<String, Object?>? fields,
      String publicKey, String apiPassword, String baseUrl) async {
    var url = '$baseUrl/meeza/api/v2/direct/transaction/requestToPay';
    return genRequestPayResponse(url, fields, publicKey, apiPassword);
  }

  Future<OrderApiResponse> genResponse(String url, Map<String, Object?>? fields,
      String publicKey, String apiPassword) async {
    genHeaders(publicKey, apiPassword);

    Dio dio=Dio(
        BaseOptions(
          baseUrl: url,
          receiveDataWhenStatusError: true,
          followRedirects: false,
          // will not throw errors
          validateStatus: (status) => true,
        )
    );

    dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90));
    dio.options.headers=headers;
    Response myResponse=await dio.post(
      url,
      data: fields
    );

    return OrderApiResponse.fromMap(myResponse.data);
    // http.Response response = await http.post(url.toUri(),
    //     body: jsonEncode(fields), headers: headers);
    // var body = response.body;
    //
    // var statusCode = response.statusCode;
    //
    // switch (statusCode) {
    //   case HttpStatus.ok:
    //     Map<String, dynamic> responseBody = json.decode(body);
    //     return OrderApiResponse.fromMap(responseBody);
    //   case HttpStatus.gatewayTimeout:
    //     throw PayException('Gateway timeout error');
    //   default:
    //     throw PayException(Strings.unKnownResponse);
    // }
  }

  Future<RequestPayApiResponse> genRequestPayResponse(String url, Map<String, Object?>? fields,
      String publicKey, String apiPassword) async {
    genHeaders(publicKey, apiPassword);

    http.Response response = await http.post(url.toUri(),
        body: jsonEncode(fields), headers: headers);
    var body = response.body;

    var statusCode = response.statusCode;

    switch (statusCode) {
      case HttpStatus.ok:
        Map<String, dynamic> responseBody = json.decode(body);
        return RequestPayApiResponse.fromMap(responseBody);
      case HttpStatus.gatewayTimeout:
        throw PayException('Gateway timeout error');
      default:
        throw PayException(Strings.unKnownResponse);
    }
  }
}
