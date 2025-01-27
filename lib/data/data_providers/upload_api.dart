import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imba/data/models/classifications_response.dart';
import 'package:imba/data/models/house_response.dart';
import 'package:path/path.dart' as path;

import '../../exceptions/app_exceptions.dart';
import '../../exceptions/login_exception.dart';
import '../../utilities/constants.dart';
import '../models/error_response.dart';
import '../models/payment_response.dart';
import '../models/request_models/house_model.dart';
import '../models/types_response.dart';

class UploadApi {
  static const String logName = 'api.app';
  final http.Client httpClient;

  UploadApi({
    required this.httpClient,
  });

  Future<TypesResponse> getTypes() async {
    try {
      final response = await http.get(Uri.parse('$BASE_URL/house/types'),
          headers: <String, String>{}).timeout(const Duration(seconds: 100));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return TypesResponse.fromJson(json);
      } else {
        var res = ErrorResponse.fromJson(jsonDecode(response.body));
        throw Exception(res.details);
      }
    } catch (e) {
      dev.log('Failed to get data: $e', name: logName);
      throw ExceptionHandler().getExceptionString(e);
    }
  }

  Future<ClassificationsResponse> getClassifications() async {
    try {
      final response = await http.get(
          Uri.parse('$BASE_URL/house/classification'),
          headers: <String, String>{}).timeout(const Duration(seconds: 100));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ClassificationsResponse.fromJson(json);
      } else {
        var res = ErrorResponse.fromJson(jsonDecode(response.body));
        throw Exception(res.details);
      }
    } catch (e) {
      dev.log('Failed to get classifications: $e', name: logName);
      throw ExceptionHandler().getExceptionString(e);
    }
  }

  Future<HouseResponse> uploadHouse(HouseRequest house, String token) async {
    try {
      final response = await http
          .post(
            Uri.parse('$BASE_URL/house/upload'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'houseAddress': house.houseAddress!,
              'area': house.area!,
              'city': house.city!,
              'occupationDate': house.occupationDate!,
              'borehole': house.boreHole!,
              'numberRooms': house.numberRooms!,
              'extraDetails': house.extraDetails!,
              'rent': house.rent!,
              'deposit': house.deposit!,
              'boreHole': house.boreHole!,
              'solar': house.solar!,
              'rentWaterInclusive': house.rentWaterInclusive!,
              'rentElectricityInclusive': house.rentElectricityInclusive!,
              'walled': house.walled!,
              'tiled': house.tiled!,
              'gated': house.gated!,
              'occupied': house.occupied,
              'token': token,
              'type': house.type,
              'classification': house.classification,
              'contact': house.contact,
              'email': house.email
            }),
          )
          .timeout(const Duration(seconds: 100));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return HouseResponse.fromJson(json);
      } else {
        var res = ErrorResponse.fromJson(jsonDecode(response.body));
        throw Exception(res.details);
      }
    } catch (e) {
      dev.log('Failed to get data: $e', name: logName);
      throw ExceptionHandler().getExceptionString(e);
    }
  }

  Future<List<HouseResponse>> getUploads(String token) async {
    try {
      final response = await http.get(
          Uri.parse('$BASE_URL/house/view/uploads?token=$token'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          }).timeout(const Duration(seconds: 100));

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        List<HouseResponse> newData = List<HouseResponse>.from(
            json.map((element) => HouseResponse.fromJson(element)));
        return newData;
      } else {
        var res = ErrorResponse.fromJson(jsonDecode(response.body));
        throw Exception(res.details);
      }
    } catch (e) {
      dev.log('Failed to get data: $e', name: logName);
      throw Exception(e);
    }
  }

  Future<PaymentResponse> getHouseById(String token, int houseId) async {
    try {
      final response = await http.get(
          Uri.parse('$BASE_URL/house/get?token=$token&houseId=$houseId'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          }).timeout(const Duration(seconds: 100));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return PaymentResponse.fromJson(json);
      } else {
        var res = ErrorResponse.fromJson(jsonDecode(response.body));
        throw Exception(res.details);
      }
    } catch (e) {
      dev.log('Failed to get data: $e', name: logName);
      throw Exception(e);
    }
  }

  Future<HouseResponse> editUpload(String token, int houseId,
      String occupationDate, bool occupied, String deposit, String rent) async {
    var newOccupationDate =
        occupationDate == "" ? "" : "&occupationDate=$occupationDate";
    var newDeposit = deposit == "" ? "" : "&deposit=$deposit";
    var newRent = rent == "" ? "" : "&rent=$rent";

    try {
      final response = await http.post(
        Uri.parse(
            '$BASE_URL/house/edit?token=$token&houseId=$houseId$newOccupationDate&occupied=$occupied$newDeposit&rent=$newRent'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: 100));

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        print(response.body.toString());
        return HouseResponse.fromJson(json);
      } else if (response.statusCode == 400 &&
          response.body ==
              '{"error":"Request could not be completed with incomplete PROFILE kindly navigate to Options tab on Home Page and complete your profile to proceed.","errorCode":400,"details":"Request data invalid"}') {
        throw Exception('Update profile first');
      } else {
        var res = ErrorResponse.fromJson(jsonDecode(response.body));
        throw Exception(res.details);
      }
    } catch (e) {
      dev.log('Failed to get data: $e', name: logName);
      throw Exception(e);
    }
  }

  Future<bool> uploadHousePics(int houseId, String tittle, String description,
      List<XFile> images) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
          '$BASE_URL/house/pic/upload?title=$tittle&description=$description&houseId=$houseId'),
    );

    for (var i = 0; i < images.length; i++) {
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        File(images[i].path).readAsBytesSync(),
        filename: path.basename(images[i].path.split("/").last),
        contentType: MediaType("image", "png"),
      ));
    }

    // send
    var response = await request.send();
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    print(responseString);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> activateHouse(int houseId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/house/activate?houseId=$houseId&token=$token'),
        headers: <String, String>{},
      ).timeout(const Duration(seconds: 100));

      if (response.statusCode == 200) {
        return true;
      }

      if (response.statusCode == 400 &&
          response.body.contains(
              "Request could not be completed with incomplete PROFILE kindly navigate to Options tab on Home Page and complete your profile to proceed.")) {
        throw Exception("not registered");
      }

      if (response.statusCode == 424) {
        // Handle payment error code specifically
        dev.log('Payment Error: ${response.body}', name: logName);
        throw Exception(response.body); // Directly throw the message
      }

      // Parse other error responses
      var res = ErrorResponse.fromJson(jsonDecode(response.body));
      dev.log('Error Response: ' + res.toString(), name: logName);
      throw Exception(res.details);
    } catch (e) {
      // Handle exceptions
      dev.log('Error: ' + e.toString(), name: logName);
      if (e is FormatException) {
        // Handle specific parsing issue
        throw Exception("Unexpected response format: ${e.message}");
      }
      throw Exception(e.toString());
    }
  }
}
