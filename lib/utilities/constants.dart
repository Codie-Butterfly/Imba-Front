import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ColorConstants {
  static const Color yellow = Color(0xffffa31a);
  static const Color opaqueYellow = Color(0xff9c8e40);
  static const Color grey = Color(0xffe6e6e6);
}

const String ACCESS_TOKEN = 'vdds.access_token';
const String IS_ACCEPTED_TERMS = "false";

const String BASE_URL = 'https://api.codiebutterfly.org';
//const String BASE_URL='http://13.246.246.19:9000';
const key = "MtraGXVtfMtQc11a";

class UtilCustom {
 static String formatDate(String date) {
    String inputDate = "2023-10-25T00:00:00.000+00:00";

    // Parse the string into a DateTime object
    DateTime parsedDate = DateTime.parse(inputDate);

    // Define the format you want
    DateFormat formatter = DateFormat('d MMMM yyyy');

    // Format the parsed date
    String formattedDate = formatter.format(parsedDate);

    return formattedDate;
  }
}
