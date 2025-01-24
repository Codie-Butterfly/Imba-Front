import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imba/bloc/appointment/appointment_state.dart';
import 'package:imba/ui/layouts/home_layout.dart';
import 'package:intl/intl.dart';

import '../../bloc/actions/actions_bloc.dart';
import '../../bloc/actions/actions_event.dart';
import '../../bloc/appointment/appointment_bloc.dart';
import '../../bloc/appointment/appointment_event.dart';
import '../../utilities/constants.dart';
import '../widgets/custom_elevated_button.dart';
import '../widgets/date_formatter.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/logo.dart';
import '../widgets/property_error_widget.dart';
import 'edit_property.dart';

class Appointment extends StatefulWidget {
  final String? action;
  final int? houseId;

  const Appointment({Key? key, this.action, this.houseId}) : super(key: key);

  @override
  State<Appointment> createState() => _AppointmentState();
}

class _AppointmentState extends State<Appointment> {
  late AppointmentBloc appointmentBloc;
  DateTime currentDate = DateTime.now();
  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  String to24hours(int hours, int minutes) {
    final hour = hours.toString().padLeft(2, "0");
    final min = minutes.toString().padLeft(2, "0");
    return "$hour:$min";
  }

  TimeOfDay _time = TimeOfDay(
      hour: (DateTime(DateTime.now().hour).hour),
      minute: (DateTime(DateTime.now().minute).minute));

  TimeOfDay startTime = TimeOfDay(
      hour: (DateTime(DateTime.now().hour).hour),
      minute: (DateTime(DateTime.now().minute).minute));

  TimeOfDay endTime = TimeOfDay(
      hour: (DateTime(DateTime.now().hour).hour),
      minute: (DateTime(DateTime.now().minute).minute));

  static GlobalKey<FormState> fkey = GlobalKey<FormState>();

  // Key for form
  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);

    String constructDate(DateTime date, TimeOfDay time) {
      String formattedTime = to24hours(time.hour, time.minute);
      return DateFormat('yyyy-MM-dd').format(date) +
          " " +
          formattedTime +
          ":00";
    }

    return HomeLayout(
      title: 'Set Appointment',
      hasBack: true,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(widget.houseId.toString(),
                    style: GoogleFonts.montserrat(
                        fontSize: 30,
                        decoration: TextDecoration.none,
                        color: ColorConstants.yellow)),
              ],
            ),
            Form(
              key: fkey,
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCustomTextField(
                        label: 'Date',
                        controller: _dateController,
                        hintText:
                            DateFormat.yMMMMd('en_US').format(currentDate),
                        onTap: () => _selectDate(context),
                      ),
                      const SizedBox(height: 10),
                      _buildCustomTextField(
                        label: 'Start Time',
                        controller: _startTimeController,
                        hintText: localizations.formatTimeOfDay(startTime),
                        onTap: () => _selectTime("start"),
                      ),
                      const SizedBox(height: 10),
                      _buildCustomTextField(
                        label: 'End Time',
                        controller: _endTimeController,
                        hintText: localizations.formatTimeOfDay(endTime),
                        onTap: () => _selectTime("end"),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 150,
                    child: BlocListener<AppointmentBloc, AppointmentState>(
                      listener: (context, state) {
                        if (state is AppointmentSuccessState) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Appointment reserved'),
                              duration: const Duration(seconds: 3),
                              action: SnackBarAction(
                                label: '',
                                onPressed: () {},
                              ),
                            ),
                          );
                        }
                        if (state is AppointmentFailedState) {
                          if (state.message.contains("not registered")) {
                            SchedulerBinding.instance.addPostFrameCallback((_) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PropertyError(
                                      errorMessage: 'Set up profile first'),
                                ),
                              );
                            });
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PropertyError(errorMessage: state.message),
                              ),
                            );
                          }
                        }
                      },
                      child: BlocBuilder<AppointmentBloc, AppointmentState>(
                        builder: (context, state) {
                          if (state is AppointmentLoadingState) {
                            return const LoadingIndicator();
                          }
                          if (state is AppointmentSuccessState) {
                            SchedulerBinding.instance!
                                .addPostFrameCallback((_) {
                              BlocProvider.of<ActionsBloc>(context)
                                  .add(ResetEvent());
                              Navigator.of(context)
                                ..pop()
                                ..pop();
                            });
                          }
                          return CustomElevateButton(
                            name: widget.action!,
                            color: ColorConstants.yellow,
                            onSubmit: () {
                              BlocProvider.of<AppointmentBloc>(context).add(
                                ReserveAppointmentEvent(
                                  houseId: widget.houseId!,
                                  token: "",
                                  startDate:
                                      constructDate(currentDate, startTime),
                                  endDate: constructDate(currentDate, endTime),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ColorConstants.yellow,
              onPrimary: Colors.black,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != currentDate) {
      setState(() {
        currentDate = pickedDate;
      });
    }
  }

  void _selectTime(String time) async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ColorConstants.yellow,
              onPrimary: Colors.black,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(),
            ),
          ),
          child: child!,
        );
      },
    );

    if (newTime != null) {
      setState(() {
        _time = newTime;
        time == "start" ? startTime = newTime : endTime = newTime;
      });
    }
  }

  Widget _buildCustomTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        Expanded(
            flex: 1,
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                color: Colors.black,
                fontSize: 16,
              ),
            )),
        Expanded(
          flex: 1,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              isDense: true,
              hintText: hintText,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: const BorderSide(
                  color: Colors.orange,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: const BorderSide(
                  color: Colors.orange,
                  width: 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: const BorderSide(
                  color: Colors.orange,
                  width: 1.0,
                ),
              ),
            ),
            style: const TextStyle(color: Colors.black),
            onTap: onTap,
            readOnly: true,
          ),
        ),
      ],
    );
  }
}
