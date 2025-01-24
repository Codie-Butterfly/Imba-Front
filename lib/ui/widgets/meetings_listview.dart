import 'dart:core';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/meeting_request_response.dart';
import '../../utilities/constants.dart';
import 'logo.dart';

class MeetingsList extends StatefulWidget {
  final List<Meetings> meetingsList;

  const MeetingsList({Key? key, required this.meetingsList}) : super(key: key);

  @override
  State<MeetingsList> createState() => _MeetingsListState();
}

class _MeetingsListState extends State<MeetingsList> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: widget.meetingsList.isNotEmpty
          ? ListView.builder(
              shrinkWrap: true,
              itemCount: widget.meetingsList.length,
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
                            flex: 1,
                            child: Column(children: [
                              Logo(
                                  imageUrl: 'assets/images/houseicon.png',
                                  width: 110.sp,
                                  height: 110.sp)
                            ])),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Text("FROM: ${widget.meetingsList[index].startDate}",
                                          Text(
                                              "FROM:" +
                                                  UtilCustom.formatDate(widget
                                                      .meetingsList[index]
                                                      .startDate!),
                                              style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: "Montserrat")),
                                          const SizedBox(height: 5),
                                          Text(
                                              "TO: " +
                                                  UtilCustom.formatDate(widget
                                                      .meetingsList[index]
                                                      .endDate!),
                                              style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: "Montserrat")),
                                        ]),
                                  ),
                                  Expanded(
                                    child: Column(children: [
                                      Text(
                                          "${widget.meetingsList[index].house!.id}\n${widget.meetingsList[index].house!.area}\n${widget.meetingsList[index].house!.city}",
                                          style: TextStyle(
                                              color: ColorConstants.yellow,
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "Montserrat")),
                                    ]),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          color: ColorConstants.grey,
                                          borderRadius:
                                              BorderRadius.circular(5.0)),
                                      child: Text(
                                          widget.meetingsList[index].approved!
                                              ? "APPROVED"
                                              : "PENDING",
                                          style: TextStyle(
                                              fontSize: 15.sp,
                                              color: Colors.black)))
                                ],
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ]),
                );
              })
          : const Text("No meetings"),
    );
  }
}
