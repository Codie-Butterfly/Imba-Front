import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imba/bloc/actions/actions_bloc.dart';
import 'package:imba/bloc/actions/actions_event.dart';
import 'package:imba/ui/layouts/home_layout.dart';
import 'package:imba/ui/screens/appointment.dart';
import 'package:imba/ui/screens/view_house.dart';
import 'package:imba/utilities/constants.dart';

import '../../bloc/actions/actions_state.dart';
import '../../bloc/payment/payment_bloc.dart';
import '../../bloc/payment/payment_event.dart';
import '../../bloc/upload/upload_bloc.dart';
import '../../bloc/upload/upload_event.dart';
import '../../bloc/views/views_bloc.dart';
import '../../bloc/views/views_event.dart';
import '../widgets/custom_elevated_button.dart';
import '../widgets/custom_textbutton.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/logo.dart';
import '../widgets/property_error_widget.dart';
import 'appointments_infinite.dart';

class ActionsOptions extends StatefulWidget {
  final int? houseId;

  const ActionsOptions({Key? key, this.houseId}) : super(key: key);

  @override
  State<ActionsOptions> createState() => _ActionsOptionsState();
}

class _ActionsOptionsState extends State<ActionsOptions> {
  @override
  Widget build(BuildContext context) {
    return HomeLayout(
        title: 'House Actions',
        hasBack: true,
        child: SingleChildScrollView(
            child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: const [
                      Logo(
                          imageUrl: 'assets/images/houseicon.png',
                          height: 100,
                          width: 100),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        CustomTextButton(
                          color: Colors.black,
                          fontSize: 20.sp,
                          name: 'Set Viewing Appointment',
                          onSubmit: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Appointment(
                                        action: 'UPDATE',
                                        houseId: widget.houseId)));
                          },
                        ),
                        BlocListener<ActionsBloc, ActionsState>(
                          listener: (context, state) {},
                          child: BlocBuilder<ActionsBloc, ActionsState>(
                              builder: (context, state) {
                            if (state is InterestLoadingState) {
                              return const LoadingIndicator();
                            }
                            if (state is InterestSuccessState) {
                              SchedulerBinding.instance!
                                  .addPostFrameCallback((_) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: const Text(
                                      'Interest initiated successfully'),
                                  action: SnackBarAction(
                                    label: "",
                                    onPressed: () {},
                                  ),
                                ));
                              });

                              SchedulerBinding.instance!
                                  .addPostFrameCallback((_) {
                                BlocProvider.of<ActionsBloc>(context)
                                    .add(ResetEvent());
                                Navigator.of(context)
                                  ..pop()
                                  ..pop();
                              });
                            }
                            if (state is InterestFailedState) {
                              if (state.message
                                  .contains("can not review your own house")) {
                                SchedulerBinding.instance!
                                    .addPostFrameCallback((_) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const PropertyError(
                                              errorMessage:
                                                  'Error!, You can not rate your own house')));
                                });
                              }
                              if (state.message.contains("not registered")) {
                                SchedulerBinding.instance!
                                    .addPostFrameCallback((_) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const PropertyError(
                                              errorMessage:
                                                  'Complete your profile first')));
                                });
                              } else {
                                SchedulerBinding.instance!
                                    .addPostFrameCallback((_) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const PropertyError(
                                              errorMessage:
                                                  'failed to initiate interest')));
                                });
                              }
                              BlocProvider.of<ActionsBloc>(context)
                                  .add(ResetEvent());
                            }

                            return CustomTextButton(
                              color: Colors.black,
                              fontSize: 20.sp,
                              name: 'Initiate House Interest',
                              onSubmit: () {
                                BlocProvider.of<ActionsBloc>(context).add(
                                    InitiateInterestEvent(
                                        houseId: widget.houseId!));
                              },
                            );
                          }),
                        ),
                        CustomTextButton(
                          color: Colors.black,
                          fontSize: 20.sp,
                          name: 'Ratings',
                          onSubmit: () {
                            showAlertDialog(context, widget.houseId!);
                          },
                        ),
                      ]),
                ),
              ],
            ),
          ),
        )));
  }

  var currentRating = 0;

  showAlertDialog(context, int houseId) {
    // Create button
    Widget okButton = BlocListener<ActionsBloc, ActionsState>(
      listener: (context, state) {},
      child: BlocBuilder<ActionsBloc, ActionsState>(builder: (context, state) {
        if (state is RateLoadingState) {
          return const LoadingIndicator();
        }
        if (state is RateSuccessState) {
          SchedulerBinding.instance!.addPostFrameCallback((_) {
            BlocProvider.of<ActionsBloc>(context).add(ResetEvent());
            BlocProvider.of<PaymentBloc>(context)
                .add(MakePaymentEvent(houseId: houseId));
          });
          SchedulerBinding.instance!.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('review added'),
              action: SnackBarAction(
                label: "",
                onPressed: () {},
              ),
            ));
            Navigator.of(context)
              ..pop()
              ..pop();
          });
        }

        if (state is RateFailedState) {
          if (state.message.contains("can not review your own house")) {
            SchedulerBinding.instance!.addPostFrameCallback((_) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PropertyError(
                          errorMessage:
                              'Error!, You can not rate your own house')));
            });

            BlocProvider.of<ActionsBloc>(context).add(ResetEvent());
          } else if (state.message.contains("not registered")) {
            SchedulerBinding.instance!.addPostFrameCallback((_) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PropertyError(
                          errorMessage: 'Complete your profile first')));
            });
          } else {
            SchedulerBinding.instance!.addPostFrameCallback((_) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          PropertyError(errorMessage: state.message)));
            });
          }

          BlocProvider.of<ActionsBloc>(context).add(ResetEvent());
        }
        return CustomElevateButton(
          name: "Rate",
          color: ColorConstants.yellow,
          fontSize: 15.sp,
          onSubmit: () {
            BlocProvider.of<ActionsBloc>(context)
                .add(RateEvent(houseId: houseId, rate: currentRating));
            BlocProvider.of<UploadBloc>(context)
                .add(GetHouseByIdEvent(houseId: houseId));
            // Navigator.pop(context);
          },
        );
      }),
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.black,
      title: Text(houseId.toString(),
          style: TextStyle(color: ColorConstants.yellow, fontSize: 20.sp),
          textAlign: TextAlign.right),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Rate this house after viewing.",
              style: TextStyle(color: ColorConstants.yellow)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RatingBar.builder(
                unratedColor: ColorConstants.grey,
                initialRating: 0,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 20.sp,
                ),
                onRatingUpdate: (rating) {
                  currentRating = rating.round();
                },
              )
            ],
          )
        ],
      ),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
