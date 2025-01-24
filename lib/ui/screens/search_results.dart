import 'package:flutter/material.dart';
import 'package:imba/ui/layouts/home_layout.dart';

import '../../utilities/constants.dart';
import '../widgets/custom_textbutton.dart';
import 'search_results_infinite_scroll.dart';

class SearchResults extends StatefulWidget {
  final String? token;
  final String? area;
  final String? city;
  final int page;
  final int size;
  final bool isBorehole;
  final bool isSolar;
  final String minRent;
  final String maxRent;
  final bool waterInclusive;
  final bool electricityInclusive;
  final bool isDeposit;
  final String contact;
  final bool isGated;
  final bool isTiled;
  final bool isWalled;
  final String classification;
  final String type;
  final String searchValue;
  final String startDate;
  final String endDate;
  final String minNumberRooms;
  final String maxNumberRooms;

  const SearchResults(
      {Key? key,
      this.city,
      this.token,
      required this.page,
      required this.size,
      required this.isBorehole,
      required this.isSolar,
      required this.minRent,
      required this.maxRent,
      required this.waterInclusive,
      required this.electricityInclusive,
      required this.isDeposit,
      required this.contact,
      required this.isGated,
      required this.isTiled,
      required this.isWalled,
      this.area,
      required this.classification,
      required this.type,
      required this.searchValue,
      required this.startDate,
      required this.endDate,
      required this.minNumberRooms,
      required this.maxNumberRooms})
      : super(key: key);

  @override
  State<SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  bool isSearch = true;
  bool isViews = false;

  @override
  Widget build(BuildContext context) {
    return HomeLayout(
      hasBack: true,
      title: 'Search Results',
      child: Expanded(
        // Adding Expanded here to bound the height
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomTextButton(
                          color:
                              isSearch ? ColorConstants.yellow : Colors.black,
                          fontSize: 20,
                          name: 'SEARCH',
                          onSubmit: () {
                            setState(() {
                              isSearch = true;
                              isViews = false;
                            });
                          },
                        ),
                        SizedBox(
                            width: 50,
                            child: Divider(
                                thickness: 5,
                                color: isSearch ? Colors.black : Colors.white)),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomTextButton(
                          color: isViews ? ColorConstants.yellow : Colors.black,
                          fontSize: 20,
                          name: 'VIEWS',
                          onSubmit: () {
                            setState(() {
                              isViews = true;
                              isSearch = false;
                            });
                          },
                        ),
                        SizedBox(
                            width: 50,
                            child: Divider(
                                thickness: 5,
                                color: isViews ? Colors.black : Colors.white)),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      "City: ${widget.city} ",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: "Montserrat",
                      ),
                    ),
                    Text(
                      "Area: ${widget.area} ",
                      style: const TextStyle(
                        color: Colors.black,
                        fontFamily: "Montserrat",
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      "Rent : ${widget.minRent}-${widget.maxRent}",
                      style: const TextStyle(
                        color: Colors.black,
                        fontFamily: "Montserrat",
                        fontSize: 20,
                      ),
                    )
                  ],
                ),
              ),
              // Wrapping ListViews with Expanded or Flexible to resolve infinite height issue
              // Expanded(
              //   child: Visibility(
              //     visible: isSearch,
              //   child: InfiniteSearchResult(
              //     isSearch: true,
              //     page: 0,
              //     size: 0,
              //     token: '', // Replace with actual token if needed
              //     searchParams: SearchParams(
              //       area: widget.area!,
              //       city: widget.city!,
              //       contact: widget.contact,
              //       electricityInclusive: widget.electricityInclusive,
              //       isBorehole: widget.isBorehole,
              //       isDeposit: widget.isDeposit,
              //       isGated: widget.isGated,
              //       isSolar: widget.isSolar,
              //       isTiled: widget.isTiled,
              //       isWalled: widget.isWalled,
              //       maxRent: widget.maxRent,
              //       minRent: widget.minRent,
              //       waterInclusive: widget.waterInclusive,
              //       classification: widget.classification,
              //       endDate: widget.endDate,
              //       searchValue: widget.searchValue,
              //       startDate: widget.startDate,
              //       type: widget.type,
              //       minRooms: widget.minNumberRooms,
              //       maxRooms: widget.maxNumberRooms,
              //     ),
              //   ),
              // ),
              // ),
              isSearch
                  ? Container(
                      //screen height - appbar height - bottom navigation bar height
                      height: MediaQuery.of(context).size.height,
                      child: InfiniteSearchResult(
                        isSearch: true,
                        page: 0,
                        size: 0,
                        token: '', // Replace with actual token if needed
                        searchParams: SearchParams(
                          area: widget.area!,
                          city: widget.city!,
                          contact: widget.contact,
                          electricityInclusive: widget.electricityInclusive,
                          isBorehole: widget.isBorehole,
                          isDeposit: widget.isDeposit,
                          isGated: widget.isGated,
                          isSolar: widget.isSolar,
                          isTiled: widget.isTiled,
                          isWalled: widget.isWalled,
                          maxRent: widget.maxRent,
                          minRent: widget.minRent,
                          waterInclusive: widget.waterInclusive,
                          classification: widget.classification,
                          endDate: widget.endDate,
                          searchValue: widget.searchValue,
                          startDate: widget.startDate,
                          type: widget.type,
                          minRooms: widget.minNumberRooms,
                          maxRooms: widget.maxNumberRooms,
                        ),
                      ),
                    )
                  : const SizedBox(),
             isViews? Container(
                height: MediaQuery.of(context).size.height,
                child: InfiniteSearchResult(
                  isSearch: false,
                  page: 0,
                  size: 0,
                  token: '', // Replace with actual token if needed
                  searchParams: SearchParams(
                    area: widget.area!,
                    city: widget.city!,
                    contact: widget.contact,
                    electricityInclusive: widget.electricityInclusive,
                    isBorehole: widget.isBorehole,
                    isDeposit: widget.isDeposit,
                    isGated: widget.isGated,
                    isSolar: widget.isSolar,
                    isTiled: widget.isTiled,
                    isWalled: widget.isWalled,
                    maxRent: widget.maxRent,
                    minRent: widget.minRent,
                    waterInclusive: widget.waterInclusive,
                    classification: widget.classification,
                    endDate: widget.endDate,
                    searchValue: widget.searchValue,
                    startDate: widget.startDate,
                    type: widget.type,
                    minRooms: widget.minNumberRooms,
                    maxRooms: widget.maxNumberRooms,
                  ),
                ),
              ) : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
