import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomUploadDetailsHeaders extends StatelessWidget {
  final String header;

  const CustomUploadDetailsHeaders({
    Key? key,
    required this.header,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left:15.0),
      child: Text(
        header,
        style: TextStyle(fontSize: 20.sp, color: Colors.black),
        textAlign: TextAlign.start,
      ),
    );
  }
}
