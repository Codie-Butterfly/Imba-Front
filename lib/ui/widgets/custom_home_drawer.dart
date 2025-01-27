import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imba/bloc/user/user_bloc.dart';
import 'package:imba/utilities/constants.dart';
import 'package:imba/utilities/encrypt_utils.dart';

import '../screens/appointments_infinite.dart';
import '../screens/lease_agreements.dart';
import '../screens/uploads.dart';
import '../screens/register.dart';
import '../screens/viewed.dart';
class CustomHomeDrawer extends StatefulWidget {
  const CustomHomeDrawer({Key? key}) : super(key: key);

  @override
  State<CustomHomeDrawer> createState() => _CustomHomeDrawerState();
}

class _CustomHomeDrawerState extends State<CustomHomeDrawer> {
  late final UserBloc _userBloc;
  late String _firstName;
  late String _email;

  @override
  void initState() {
    super.initState();
    _userBloc = BlocProvider.of<UserBloc>(context);

    // Retrieve and decrypt user details from the UserBloc
    _firstName = _userBloc.firstName.isNotEmpty
        ? _decryptUserData(_userBloc.firstName)
        : 'First Name'; // Default value

    _email = _userBloc.email.isNotEmpty
        ? _decryptUserData(_userBloc.email)
        : 'user@example.com'; // Default value
  }

  String _decryptUserData(String data) {
    try {
      return data.isEmpty ? '' : decryptAES(data, key);
    } catch (e) {
      // If decryption fails, return the original data
      return data;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: 35, // Adjust the size as needed
                      backgroundImage: AssetImage(
                        'assets/images/avatar.jpg',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _firstName,
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 18.sp,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _email,
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.white,
                ),
                title: Text(
                  'Appointments',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AppointmentInfinite(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.assignment_outlined,
                  color: Colors.white,
                ),
                title: Text(
                  'Lease Agreements',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LeaseAgreements(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.cloud_upload_outlined,
                  color: Colors.white,
                ),
                title: Text(
                  'Uploads',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UploadsList(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.visibility_outlined,
                  color: Colors.white,
                ),
                title: Text(
                  'Views',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Viewed(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.person_outline,
                  color: Colors.white,
                ),
                title: Text(
                  'Profile',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Register(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
