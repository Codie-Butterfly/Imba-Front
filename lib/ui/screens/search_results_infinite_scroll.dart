import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:imba/ui/screens/appointment.dart';
import 'package:imba/ui/screens/view_house.dart';

import '../../data/models/search_response_model.dart';
import '../../secure_storage/secure_storage_manager.dart';
import '../../utilities/constants.dart';
import '../widgets/custom_elevated_button.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/logo.dart';

class SearchParams {
  final String area;
  final String city;
  final String searchValue;
  final String startDate;
  final String endDate;
  final String type;
  final String classification;
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
  final String minRooms;
  final String maxRooms;

  SearchParams({
    required this.area,
    required this.city,
    required this.searchValue,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.classification,
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
    required this.minRooms,
    required this.maxRooms,
  });
}

class InfiniteSearchResult extends StatefulWidget {
  final String token;
  final int page;
  final int size;
  final bool isSearch;
  final SearchParams searchParams;

  const InfiniteSearchResult({
    Key? key,
    required this.token,
    required this.page,
    required this.size,
    required this.isSearch,
    required this.searchParams,
  }) : super(key: key);

  @override
  State<InfiniteSearchResult> createState() => _InfiniteSearchResultState();
}

class _InfiniteSearchResultState extends State<InfiniteSearchResult> {
  int _page = 0;
  final int _limit = 10;
  bool _hasNextPage = true;
  bool _isFirstLoadRunning = false;
  bool _isLoadMoreRunning = false;
  List<SearchedList> searchList = [];
  List<ViewedList> viewedList = [];
  final SecureStorageManager _secureStorageManager = SecureStorageManager();
  Object errorMessage = "";
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _firstLoad();
    _controller = ScrollController()..addListener(_loadMore);
  }

  @override
  void dispose() {
    _controller.removeListener(_loadMore);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _firstLoad() async {
    setState(() => _isFirstLoadRunning = true);
    await _fetchData();
    setState(() => _isFirstLoadRunning = false);
  }

  Future<void> _fetchData() async {
    try {
      var token = await _secureStorageManager.getToken();
      final res = await http.get(Uri.parse(_buildUrl(token)));
      final json = jsonDecode(res.body);
      setState(() {
        widget.isSearch
            ? searchList = SearchResponse.fromJson(json).searchedList
            : viewedList = SearchResponse.fromJson(json).viewedList;
      });
    } catch (err) {
      if (kDebugMode) {
        print(err);
        setState(() => errorMessage = err);
      }
    }
  }

  String _buildUrl(String token) {
    final params = widget.searchParams;
    return "$BASE_URL/house/list?"
        "page=$_page&size=$_limit&area=${params.area}&city=${params.city}"
        "&searchValue=${params.searchValue}&startDate=${params.startDate}"
        "&type=${params.type}&classification=${params.classification}"
        "&endDate=${params.endDate}&borehole=${params.isBorehole}"
        "&solar=${params.isSolar}&minRent=${params.minRent}&maxRent=${params.maxRent}"
        "&rentWaterInclusive=${params.waterInclusive}"
        "&rentElectricityInclusive=${params.electricityInclusive}"
        "&needsDeposit=${params.isDeposit}&token=$token&contact=${params.contact}"
        "&gated=${params.isGated}&tiled=${params.isTiled}&walled=${params.isWalled}"
        "&minNumberRooms=${params.minRooms}&maxNumberRooms=${params.maxRooms}";
  }

  Future<void> _loadMore() async {
    if (_hasNextPage &&
        !_isFirstLoadRunning &&
        !_isLoadMoreRunning &&
        _controller.position.extentAfter < 300) {
      setState(() => _isLoadMoreRunning = true);
      _page += 1;
      await _fetchData();
      setState(() => _isLoadMoreRunning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listLength = widget.isSearch ? searchList.length : viewedList.length;
    return _isFirstLoadRunning
        ? const Center(child: LoadingIndicator())
        : listLength < 1
            ? _buildEmptyState()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildListView(listLength),
              );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        height: 500,
        width: 500,
        alignment: Alignment.center,
        child: const Text("No properties found",
            style: TextStyle(fontSize: 30, color: Colors.black)),
      ),
    );
  }

  Widget _buildListView(int listLength) {
    return Expanded(
      child: Column(
        children: [
          // Ensure ListView.builder has limited height

          ListView.builder(
            shrinkWrap: true,
            controller: _controller,
            itemCount: listLength,
            itemBuilder: (_, index) => _buildListItem(index),
          ),

          if (_isLoadMoreRunning) _buildLoadingIndicator(),
          if (!_hasNextPage) _buildNoMoreContentIndicator(),
        ],
      ),
    );
  }

  Widget _buildListItem(int index) {
    final dynamic item =
        widget.isSearch ? searchList[index] : viewedList[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0), // Rounded corners
        border: Border.all(
            color: Colors.grey.withOpacity(0.6), width: 0.8), // Grey outline
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => _navigateToViewHouse(item.id),
              child: const Logo(
                  imageUrl: 'assets/images/houseicon.png',
                  height: 100,
                  width: 100),
            ),
          ),
          Expanded(
            flex: 3,
            child: _buildItemDetails(item),
          ),
          Expanded(
            flex: 1,
            child: Text(
              item.numberRooms.toString(),
              style:
                  const TextStyle(color: ColorConstants.yellow, fontSize: 17),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  "${item.currency}${item.rent}",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Montserrat",
                  ),
                ),
                CustomElevateButton(
                  name: widget.isSearch ? "VIEW" : "RESERVE",
                  color: Colors.black,
                  fontSize: 10,
                  onSubmit: () => _handleButtonPress(item.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemDetails(item) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isSearch ? item.id.toString() : item.houseAddress,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: "Montserrat",
            ),
          ),
          Text(
            widget.isSearch ? item.area : item.area,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: "Montserrat",
            ),
          ),
          Text(
            widget.isSearch ? item.city : item.city,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: "Montserrat",
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToViewHouse(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewHouse(id: id, flag: "actions"),
      ),
    );
  }

  void _handleButtonPress(int id) {
    widget.isSearch
        ? _navigateToViewHouse(id)
        : WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    Appointment(action: 'UPDATE', houseId: id),
              ),
            );
          });
  }

  static Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.only(top: 10, bottom: 40),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  static Widget _buildNoMoreContentIndicator() {
    return Container(
      padding: const EdgeInsets.only(top: 30, bottom: 40),
      color: Colors.amber,
      child: const Center(
        child: Text('You have fetched all of the content'),
      ),
    );
  }
}
