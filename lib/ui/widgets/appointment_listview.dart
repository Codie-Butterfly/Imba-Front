import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imba/data/models/meeting_request_response.dart';
import 'package:imba/ui/widgets/property_error_widget.dart';

import '../../bloc/appointment/appointment_bloc.dart';
import '../../bloc/appointment/appointment_event.dart';
import '../../bloc/approve/approve_bloc.dart';
import '../../bloc/approve/approve_event.dart';
import '../../bloc/approve/approve_state.dart';
import '../../utilities/constants.dart';
import 'custom_elevated_button.dart';
import 'loading_indicator.dart';
import 'logo.dart';

class AppointmentListView extends StatefulWidget {
  final List<Requests> requestsList;
  const AppointmentListView({
    Key? key,
    required this.requestsList,
  }) : super(key: key);

  @override
  State<AppointmentListView> createState() => _AppointmentListViewState();
}

class _AppointmentListViewState extends State<AppointmentListView> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: widget.requestsList.isNotEmpty
          ? ListView.builder(
              shrinkWrap: true,
              itemCount: widget.requestsList.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0), // Rounded corners
                    border: Border.all(
                        color: Colors.grey.withOpacity(0.6),
                        width: 0.8), // Grey outline
                  ),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                            child: Column(children: const [
                          Logo(
                              imageUrl: 'assets/images/houseicon.png',
                              width: 100,
                              height: 100)
                        ])),
                        Expanded(
                          child: Column(children: [
                            Text(
                                "FROM: " +
                                    DateTime.parse(widget
                                            .requestsList[index].startDate!)
                                        .toLocal()
                                        .toString(),
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Montserrat")),
                            Text(
                                "TO: " +
                                    DateTime.parse(
                                            widget.requestsList[index].endDate!)
                                        .toLocal()
                                        .toString(),
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Montserrat")),
                            SizedBox(
                              height: 10,
                            ),
                            _isApproved(widget.requestsList[index].approved!,
                                        widget.requestsList[index].rejected!) ==
                                    "Pending"
                                ? CustomElevateButton(
                                    name: 'Approve',
                                    color: ColorConstants.yellow,
                                    onSubmit: () {
                                      _showAlertDialog(
                                          true,
                                          widget.requestsList[index].requestId!,
                                          context);
                                    })
                                : _isApproved(
                                            widget
                                                .requestsList[index].approved!,
                                            widget.requestsList[index]
                                                .rejected!) ==
                                        "Approved"
                                    ? Container(
                                        color: ColorConstants.grey,
                                        child: Text("APPROVED",
                                            style: TextStyle(fontSize: 15.sp)))
                                    : Container(
                                        color: ColorConstants.grey,
                                        child: Text("",
                                            style: TextStyle(fontSize: 15.sp)))
                          ]),
                        ),
                        Expanded(
                            child: Column(children: [
                          Text(
                              "${widget.requestsList[index].house!.id!}\n${widget.requestsList[index].house!.area!}\n${widget.requestsList[index].house!.city!}",
                              style: const TextStyle(
                                  color: ColorConstants.yellow,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Montserrat")),
                          SizedBox(
                            height: 10,
                          ),
                          _isApproved(widget.requestsList[index].approved!,
                                      widget.requestsList[index].rejected!) ==
                                  "Pending"
                              ? CustomElevateButton(
                                  name: 'REJECT',
                                  color: ColorConstants.yellow,
                                  onSubmit: () {
                                    _showAlertDialog(
                                        false,
                                        widget.requestsList[index].requestId!,
                                        context);
                                  })
                              : _isApproved(
                                          widget.requestsList[index].approved!,
                                          widget
                                              .requestsList[index].rejected!) ==
                                      "Rejected"
                                  ? Container(
                                      color: ColorConstants.grey,
                                      child: Text("REJECTED",
                                          style: TextStyle(fontSize: 15.sp)))
                                  : Container(
                                      color: ColorConstants.grey,
                                      child: Text("",
                                          style: TextStyle(fontSize: 15.sp)))
                        ])),
                      ]),
                );
              })
          : const Text("No requests"),
    );
  }

  String _isApproved(bool isApproved, bool isRejected) {
    if (!isApproved && isRejected) {
      return "Rejected";
    } else if (isApproved && !isRejected) {
      return "Approved";
    } else {
      return 'Pending';
    }
  }

  Future<void> _showAlertDialog(bool approved, int requestId, context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.center, // <-- SEE HERE

          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  approved ? "Approve appointment" : "Reject Appointment",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            approved
                ? BlocListener<ApproveBloc, ApproveState>(
                    listener: (context, state) {
                    if (state is ApproveSuccessState) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('success'),
                        duration: const Duration(seconds: 1),
                        action: SnackBarAction(
                          label: '',
                          onPressed: () {},
                        ),
                      ));
                      BlocProvider.of<AppointmentBloc>(context)
                          .add(GetMeetingsAndRequestEvent());
                      BlocProvider.of<ApproveBloc>(context)
                          .add(ApproveRefreshEvent());
                    }
                    if (state is ApproveFailedState) {
                      SchedulerBinding.instance!.addPostFrameCallback((_) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PropertyError(
                                    errorMessage: state.message)));
                      });
                    }
                  }, child: BlocBuilder<ApproveBloc, ApproveState>(
                        builder: (context, state) {
                    if (state is ApproveLoadingState) {
                      return const LoadingIndicator();
                    }
                    if (state is ApproveSuccessState) {
                      BlocProvider.of<AppointmentBloc>(context)
                          .add(GetMeetingsAndRequestEvent());
                      BlocProvider.of<ApproveBloc>(context)
                          .add(ApproveRefreshEvent());

                      Navigator.pop(context);
                    }
                    if (state is ApproveFailedState) {
                      // SchedulerBinding.instance!.addPostFrameCallback((_) {
                      //   Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //           builder: (context) => PropertyError(
                      //               errorMessage: state.message)));
                      // });
                    }
                    return TextButton(
                      child: const Text('Yes'),
                      onPressed: () {
                        BlocProvider.of<ApproveBloc>(context)
                            .add(ApproveRequestEvent(
                          approved: approved,
                          requestId: requestId,
                        ));
                      },
                    );
                  }))
                : BlocListener<ApproveBloc, ApproveState>(
                    listener: (context, state) {
                    if (state is RejectSuccessState) {
                      BlocProvider.of<AppointmentBloc>(context)
                          .add(GetMeetingsAndRequestEvent());
                    }
                    if (state is RejectFailedState) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PropertyError(errorMessage: state.message)));
                    }
                  }, child: BlocBuilder<ApproveBloc, ApproveState>(
                        builder: (context, state) {
                    if (state is RejectLoadingState) {
                      return const LoadingIndicator();
                    }
                    if (state is RejectSuccessState) {
                      BlocProvider.of<AppointmentBloc>(context)
                          .add(GetMeetingsAndRequestEvent());
                      BlocProvider.of<ApproveBloc>(context)
                          .add(ApproveRefreshEvent());
                      Navigator.pop(context);
                    }
                    if (state is RejectFailedState) {
                      // SchedulerBinding.instance!.addPostFrameCallback((_) {
                      //   Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //           builder: (context) => PropertyError(
                      //               errorMessage: state.message)));
                      // });
                    }

                    return TextButton(
                      child: const Text('Yes'),
                      onPressed: () {
                        BlocProvider.of<ApproveBloc>(context)
                            .add(RejectRequestEvent(
                          approved: approved,
                          requestId: requestId,
                        ));
                      },
                    );
                  }))
          ],
        );
      },
    );
  }
}
