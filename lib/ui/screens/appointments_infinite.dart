import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../bloc/appointment/appointment_bloc.dart';
import '../../bloc/appointment/appointment_event.dart';
import '../../bloc/appointment/appointment_state.dart';
import '../../data/models/meeting_request_response.dart';
import '../../data/models/search_response_model.dart';
import '../../secure_storage/secure_storage_manager.dart';
import '../../utilities/constants.dart';
import '../widgets/appointment_listview.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_elevated_button.dart';
import '../widgets/custom_textbutton.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/meetings_listview.dart';
import '../layouts/home_layout.dart';

class AppointmentInfinite extends StatefulWidget {
  const AppointmentInfinite({Key? key}) : super(key: key);

  @override
  State<AppointmentInfinite> createState() => _AppointmentInfiniteState();
}

class _AppointmentInfiniteState extends State<AppointmentInfinite> {
  bool isRequest = false;
  bool isMeeting = true;
  MeetingRequestsResponse? resp;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<AppointmentBloc>(context).add(GetMeetingsAndRequestEvent());
  }

  @override
  Widget build(BuildContext context) {
    return HomeLayout(
      hasBack: true,
      title: "Appointments",
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildTabs(),
            BlocListener<AppointmentBloc, AppointmentState>(
              listener: (context, state) {
                if (state is AppointmentFailedState) {
                  _showSnackBar(context, 'Failed to load');
                }
              },
              child: BlocBuilder<AppointmentBloc, AppointmentState>(
                builder: (context, state) {
                  if (state is AppointmentLoadingState) {
                    return const LoadingIndicator();
                  } else if (state is MeetingsAndRequestsSuccessState) {
                    resp = state.meetingRequestsResponse;
                    return _buildContent(state);
                  } else if (state is AppointmentFailedState) {
                    return _buildErrorState(context, state.message);
                  }
                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: ColorConstants.yellow,
      height: 50,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "APPOINTMENTS",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            fontFamily: "Montserrat",
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          _buildTabButton("MEETINGS", isMeeting, () {
            BlocProvider.of<AppointmentBloc>(context)
                .add(GetMeetingsAndRequestEvent());
            setState(() {
              isMeeting = true;
              isRequest = false;
            });
          }),
          const SizedBox(width: 10),
          _buildTabButton("REQUESTS", isRequest, () {
            BlocProvider.of<AppointmentBloc>(context)
                .add(GetMeetingsAndRequestEvent());
            setState(() {
              isRequest = true;
              isMeeting = false;
            });
          }),
        ],
      ),
    );
  }

  Widget _buildTabButton(String name, bool isActive, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomTextButton(
          color: isActive ? ColorConstants.yellow : Colors.black,
          fontSize: 20,
          name: name,
          onSubmit: onTap,
        ),
        SizedBox(
          width: 50,
          child: Divider(
            thickness: 5,
            color: isActive ? Colors.black : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(MeetingsAndRequestsSuccessState state) {
    final hasMeetings =
        state.meetingRequestsResponse.meetings?.isNotEmpty ?? false;
    final hasRequests =
        state.meetingRequestsResponse.requests?.isNotEmpty ?? false;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Visibility(
            visible: isMeeting,
            child: hasMeetings
                ? SingleChildScrollView(
                    child: MeetingsList(
                      meetingsList: state.meetingRequestsResponse.meetings!,
                    ),
                  )
                : _buildEmptyState("No Meetings Available"),
          ),
          Visibility(
            visible: isRequest,
            child: hasRequests
                ? SingleChildScrollView(
                    child: AppointmentListView(
                      requestsList: state.meetingRequestsResponse.requests!,
                    ),
                  )
                : _buildEmptyState("No Requests Available"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          //EMPTY ICON
          const Icon(
            Icons.hourglass_empty,
            size: 100,
            color: Colors.black54,
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: GoogleFonts.montserrat(
              color: Colors.black54,
              fontSize: 20.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Container(
      height: 500,
      width: 500,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Text(message)),
          CustomElevateButton(
            onSubmit: () {
              BlocProvider.of<AppointmentBloc>(context)
                  .add(GetMeetingsAndRequestEvent());
            },
            color: ColorConstants.yellow,
            name: "Retry",
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 1),
    ));
  }
}
