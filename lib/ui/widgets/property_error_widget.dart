import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imba/ui/widgets/custom_elevated_button.dart';

import '../../utilities/constants.dart';
import 'logo.dart';

class PropertyError extends StatelessWidget {
  final String errorMessage;

  const PropertyError({Key? key, required this.errorMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Logo(
              imageUrl: 'assets/images/houseicon.png', height: 200, width: 200),
          Text("ERROR !",
              style: TextStyle(
                  color: Colors.red,
                  fontFamily: "Montserrat",
                  fontSize: 25.sp)),
          const SizedBox(height: 15),
          Text(errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: "Montserrat",
                  fontSize: 20.sp,
                  color: Colors.red)),
          const SizedBox(height: 15),
          CustomElevateButton(
            name: 'Try Again',
            color: Colors.red,
            onSubmit: () {
              //navigate back to search page
              Navigator.pop(context);
            },
          )
        ]),
      ),
    );
  }
}
