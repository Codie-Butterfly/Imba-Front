import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imba/bloc/activate/activate_state.dart';
import 'package:imba/bloc/upload/upload_bloc.dart';
import 'package:imba/bloc/upload/upload_state.dart';
import 'package:imba/data/models/payment_response.dart';
import 'package:imba/ui/layouts/home_layout.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../bloc/activate/activate_bloc.dart';
import '../../bloc/activate/activate_event.dart';
import '../../bloc/upload/upload_event.dart';
import '../../utilities/constants.dart';
import '../widgets/custom_elevated_button.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/logo.dart';
import '../widgets/property_error_widget.dart';
import 'actions_options.dart';
import 'edit_property.dart';

class PropertyDetails extends StatefulWidget {
  final int id;
  final String flag;

  const PropertyDetails({Key? key, required this.id, required this.flag})
      : super(key: key);

  @override
  State<PropertyDetails> createState() => _PropertyDetailsState();
}

class _PropertyDetailsState extends State<PropertyDetails> {
  late PageController _pageController;
  late PaymentResponse houseDetails;
  bool isActivated = false;
  List<String> images = [];
  final List<String> placeholders = [
    'assets/images/placeholder1.jpg',
    'assets/images/placeholder2.jpg',
    'assets/images/placeholder3.jpg',
    'assets/images/placeholder4.jpg',
    'assets/images/placeholder5.jpg'
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8);
    BlocProvider.of<ActivateBloc>(context).add(ActivationResetEvent());
    BlocProvider.of<UploadBloc>(context)
        .add(GetHouseByIdEvent(houseId: widget.id));
  }

  void _processImageUrls(List<Pics> pics) {
    if (pics.isNotEmpty) {
      images = pics
          .map((pic) =>
              "http://api.codiebutterfly.com/house/${pic.id}/image/download")
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return HomeLayout(
      hasBack: true,
      title: "Property Details", // We will update the title based on the state
      actions: [
        //edit icon button
        IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined)),
      ],
      child: BlocBuilder<UploadBloc, UploadState>(
        builder: (context, state) {
          if (state is GetHouseByIdSuccess) {
            // Assign the house details and activate status
            houseDetails = state.houseResponse;
            isActivated = state.houseResponse.house!.activated!;
            _processImageUrls(state.houseResponse.pics!);

            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCarousel(),
                      const SizedBox(height: 15),
                      _buildPropertyInfo(state.houseResponse),
                      const Divider(),
                      _buildContactInfo(state.houseResponse),
                      const SizedBox(height: 15),
                      _buildActivateButton(),
                    ],
                  ),
                ),
              ),
            );
          }

          return const LoadingIndicator();
        },
      ),
    );
  }

  Widget _buildCarousel() {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _pageController,
        itemCount: images.isNotEmpty ? images.length : placeholders.length,
        itemBuilder: (context, index) {
          final imageUrl =
              images.isNotEmpty ? images[index] : placeholders[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPropertyInfo(PaymentResponse houseResponse) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIconLabeledInfo(
                  Icons.king_bed, '${houseResponse.house!.numberRooms} Rooms'),
              _buildIconLabeledInfo(Icons.home, houseResponse.house!.type!),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIconLabeledInfo(Icons.location_on,
                  '${houseResponse.house!.houseAddress}, ${houseResponse.house!.city}'),
              Row(
                children: [
                  const Icon(Icons.attach_money, color: Colors.orange),
                  const SizedBox(width: 5),
                  Text(
                    '${houseResponse.house!.currency}${houseResponse.house!.rent!}',
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconLabeledInfo(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(icon, color: ColorConstants.yellow),
        const SizedBox(width: 5),
        Text(
          text,
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo(PaymentResponse houseResponse) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Contact Details",
            style: GoogleFonts.montserrat(
              color: ColorConstants.yellow,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.email, color: Colors.orange),
              const SizedBox(width: 5),
              Text(
                houseResponse.house!.email!,
                style: GoogleFonts.montserrat(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.phone, color: Colors.orange),
              const SizedBox(width: 5),
              Text(
                houseResponse.house!.contact!,
                style: GoogleFonts.montserrat(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivateButton() {
    return BlocBuilder<ActivateBloc, ActivateState>(builder: (context, state) {
      if (state is ActivateLoadingState) {
        return const LoadingIndicator();
      }

      if (state is ActivateHouseSuccess) {
        isActivated = state.isActivated!;
        if (isActivated) {
          BlocProvider.of<ActivateBloc>(context).add(ActivationResetEvent());
        }
      }

      if (state is ActivateFailedState) {
        SchedulerBinding.instance!.addPostFrameCallback((_) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PropertyError(errorMessage: state.message),
            ),
          );
        });
      }

      return CustomElevateButton(
        name: isActivated ? 'EDIT' : 'ACTIVATE',
        color: ColorConstants.yellow,
        onSubmit: () {
          if (isActivated) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProperty(
                  houseId: widget.id,
                  deposit: houseDetails.house!.deposit!,
                  occupationDate: houseDetails.house!.occupationDate.toString(),
                  occupied: houseDetails.house!.occupied!,
                  rent: houseDetails.house!.rent!,
                ),
              ),
            );
          } else {
            BlocProvider.of<ActivateBloc>(context)
                .add(ActivateHouseEvent(houseId: widget.id));

            context.read<ActivateBloc>().stream.listen((activateState) {
              if (activateState is ActivateHouseSuccess) {
                _showSnackBar(context, 'Property activated successfully');
              } else if (activateState is ActivateFailedState) {
                _showSnackBar(context, activateState.message);
              }
            });
          }
        },
      );
    });
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
