import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imba/bloc/upload/upload_bloc.dart';
import 'package:imba/bloc/upload/upload_event.dart';
import 'package:imba/bloc/upload/upload_state.dart';
import 'package:imba/data/models/house_response.dart';
import 'package:imba/ui/layouts/home_layout.dart';
import 'package:imba/utilities/constants.dart';
import 'package:imba/ui/widgets/custom_appbar.dart';
import 'package:imba/ui/widgets/custom_elevated_button.dart';
import 'package:imba/ui/widgets/custom_listview.dart';
import 'package:imba/ui/widgets/loading_indicator.dart';

class UploadsList extends StatefulWidget {
  const UploadsList({Key? key}) : super(key: key);

  @override
  State<UploadsList> createState() => _UploadsListState();
}

class _UploadsListState extends State<UploadsList> with RouteAware {
  List<HouseResponse> resp = [];

  @override
  void initState() {
    super.initState();
    _fetchUploads();
    // Register the route observer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = ModalRoute.of(context);
      if (route is PageRoute) {
        routeObserver.subscribe(this, route);
      }
    });
  }

  @override
  void dispose() {
    // Unregister the route observer
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when the current route has been popped off and the user returns to this route
    _fetchUploads();
  }

  void _fetchUploads() {
    final uploadBloc = BlocProvider.of<UploadBloc>(context);
    uploadBloc.add(GetUploadsEvent());
    uploadBloc.add(ResetUploadsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return HomeLayout(
      title: "Your Uploads",
      hasBack: true,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(),
              _buildDivider(),
              BlocListener<UploadBloc, UploadState>(
                listener: _blocListener,
                child: BlocBuilder<UploadBloc, UploadState>(
                  builder: (context, state) => _buildContent(state),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      "UPLOADS",
      style: GoogleFonts.montserrat(
        fontSize: 20.sp,
        decoration: TextDecoration.none,
        color: ColorConstants.yellow,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDivider() {
    return const Stack(
      children: [
        Divider(),
        SizedBox(
          width: 50,
          child: Divider(thickness: 5, color: Colors.black),
        ),
      ],
    );
  }

  void _blocListener(BuildContext context, UploadState state) {
    if (state is GetUploadsSuccessState) {
      _showSnackBar(context, 'Loaded');
    } else if (state is UploadFailedState) {
      _showSnackBar(context, 'Failed to load');
      _fetchUploads();
    }
  }

  Widget _buildContent(UploadState state) {
    if (state is UploadLoadingState) {
      return const LoadingIndicator();
    } else if (state is GetUploadsSuccessState) {
      return _buildUploadsList(state.uploadsResponse);
    } else if (state is UploadFailedState) {
      return _buildErrorState(state.message);
    } else {
      return _buildEmptyState();
    }
  }

  Widget _buildUploadsList(List<HouseResponse> uploads) {
    if (uploads.isEmpty) {
      return _buildEmptyState();
    } else {
      return CustomListView(
        uploadsResponse: uploads,
        isPage: "uploads",
      );
    }
  }

  Widget _buildEmptyState() {
    return Container(
      height: 500,
      width: 500,
      alignment: Alignment.center,
      child: const Center(
        child: Text("Nothing here"),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      height: 500,
      width: 500,
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Text(message)),
          CustomElevateButton(
            onSubmit: _fetchUploads,
            color: ColorConstants.yellow,
            name: "Retry",
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      action: SnackBarAction(
        label: 'Close',
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
      content: Container(
        height: 30,
        padding: const EdgeInsets.all(5),
        alignment: Alignment.centerLeft,
        child: Text(
          message,
          style: GoogleFonts.montserrat(
            fontSize: 18.sp,
            color: Colors.white,
          ),
        ),
      ),
      duration: const Duration(seconds: 1),
    ));
  }
}

// Define a global route observer
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();