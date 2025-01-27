import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imba/bloc/activate/activate_state.dart';
import 'package:imba/bloc/payment/payment_event.dart';
import 'package:imba/ui/layouts/home_layout.dart';
import 'package:intl/intl.dart';

import '../../bloc/activate/activate_bloc.dart';
import '../../bloc/activate/activate_event.dart';
import '../../bloc/payment/payment_bloc.dart';
import '../../bloc/payment/payment_state.dart';
import '../../data/models/payment_response.dart';
import '../../utilities/constants.dart';
import '../widgets/custom_elevated_button.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/logo.dart';
import '../widgets/maps_widget.dart';
import '../widgets/property_error_widget.dart';
import 'actions_options.dart';
import 'appointment.dart';

class ViewHouse extends StatefulWidget {
  final int id;
  final String flag;

  const ViewHouse({Key? key, required this.id, required this.flag})
      : super(key: key);

  @override
  State<ViewHouse> createState() => _ViewHouseState();
}

class _ViewHouseState extends State<ViewHouse> {
  late PageController _pageController;

  @override
  void initState() {
    BlocProvider.of<PaymentBloc>(context)
        .add(MakePaymentEvent(houseId: widget.id));
    super.initState();
    _pageController = PageController(viewportFraction: 0.8);
  }

  List<String> images = [];
  void _processImageUrls(List<Pics> pics) {
    if (pics.isNotEmpty) {
      for (var element in pics) {
        images.add(
            "http://api.codiebutterfly.com/house/${element.id}/image/download");
      }
    }
  }

  List<String> placeholders = [
    'assets/images/placeholder1.jpg',
    'assets/images/placeholder2.jpg',
    'assets/images/placeholder3.jpg',
    'assets/images/placeholder4.jpg',
    'assets/images/placeholder5.jpg'
  ];

  var isActivated = false;

  @override
  Widget build(BuildContext context) {
    return HomeLayout(
        child: BlocBuilder<PaymentBloc, PaymentState>(
          builder: (context, state) {
            if (state is PaymentSuccessState) {
              // List<Pics> pics = state.paymentResponse.pics!;
              // _processImageUrls(pics);

              return SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 2,
                  child: Column(
                    children: [
                      // SizedBox(
                      //   width: MediaQuery.of(context).size.width,
                      //   height: MediaQuery.of(context).size.height * 0.4,
                      //   child: CarouselSlider(
                      //     options: CarouselOptions(
                      //       viewportFraction: 1,
                      //       height: MediaQuery.of(context).size.height * 0.4,
                      //       enlargeCenterPage: true,
                      //       onPageChanged: (position, reason) {
                      //         print(reason);
                      //         print(CarouselPageChangedReason.controller);
                      //       },
                      //       enableInfiniteScroll: false,
                      //     ),
                      //     items:images.isNotEmpty? images.map<Widget>((i) {
                      //       return Builder(
                      //         builder: (BuildContext context) {
                      //           return SizedBox(
                      //             width: MediaQuery.of(context).size.width,
                      //             height: MediaQuery.of(context).size.height * 0.5,
                      //             // margin: EdgeInsets.all(10),
                      //             child: Image.network(
                      //               i,
                      //               fit: BoxFit.cover,
                      //               width: MediaQuery.of(context).size.width,
                      //               height: MediaQuery.of(context).size.height * 0.4,
                      //             )
                      //           );
                      //         },
                      //       );
                      //     }).toList():
                      //     placeholders.map<Widget>((i) {
                      //       return Builder(
                      //         builder: (BuildContext context) {
                      //           return SizedBox(
                      //               width: MediaQuery.of(context).size.width,
                      //               height: MediaQuery.of(context).size.height * 0.5,
                      //               // margin: EdgeInsets.all(10),
                      //               child: Image.asset(
                      //                 i,
                      //                 fit: BoxFit.cover,
                      //                 width: MediaQuery.of(context).size.width,
                      //                 height: MediaQuery.of(context).size.height * 0.4,
                      //               )
                      //           );
                      //         },
                      //       );
                      //     }).toList()
                      //     ,
                      //   ),
                      // ),
                      _buildCarousel(),
                      const SizedBox(height: 15),
                      _buildPropertyInfo(state.paymentResponse),
                      const Divider(),
                      _buildMoreDetails(state.paymentResponse),
                      const Divider(),
                      _buildContactInfo(state.paymentResponse),
                      const SizedBox(height: 15),
                      //actions buttons
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RatingBar.builder(
                              ignoreGestures: true,
                              unratedColor: ColorConstants.grey,
                              initialRating:
                                  state.paymentResponse.house!.rate!.toDouble(),
                              minRating: 0,
                              direction: Axis.horizontal,
                              //  allowHalfRating: true,
                              itemCount: 5,
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 10.sp,
                              ),
                              onRatingUpdate: (initialRating) {
                                print(initialRating);
                              },
                            ),
                            buildActionButtons(context, isActivated,
                                widget.flag, state.paymentResponse.house!.id!),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state is PaymentFailedState) {
              return PropertyError(errorMessage: state.message);
            }

            return const LoadingIndicator();
          },
        ),
        hasBack: true,
        title: 'View Property');
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
              InkWell(
                onTap: () {
                  List<String> result =
                      houseResponse.house!.gpsLocation!.split(',');
                  // MapUtils.openMap(double.parse(result[0]),double.parse(result[1]));
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MapScreen(
                              latitude: double.parse(result[0]),
                              longitude: double.parse(result[1]))));
                },
                child: _buildIconLabeledInfo(Icons.location_on,
                    '${houseResponse.house!.houseAddress}, ${houseResponse.house!.city}'),
              ),
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
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.calendar_month_outlined, color: Colors.orange),
              const SizedBox(width: 5),
              Text(
                UtilCustom.formatDate(
                    houseResponse.house!.occupationDate ?? ""),
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

  Widget _buildMoreDetails(PaymentResponse houseResponse) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "House Features",
            style: GoogleFonts.montserrat(
              color: ColorConstants.yellow,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),

          // Wrap widget for grid layout
          Wrap(
            spacing: 40, // Horizontal space between items
            runSpacing: 10, // Vertical space between lines
            children: [
              _buildFeatureItem(houseResponse.house!.solar, "Solar"),
              _buildFeatureItem(houseResponse.house!.boreHole, "Borehole"),
              _buildFeatureItem(houseResponse.house!.rentWaterInclusive,
                  "Rent Includes Water"),
              _buildFeatureItem(houseResponse.house!.rentElectricityInclusive,
                  "Rent Includes Electricity"),
              _buildFeatureItem(houseResponse.house!.gated, "Gated"),
              _buildFeatureItem(houseResponse.house!.tiled, "Tiled"),
              _buildFeatureItem(houseResponse.house!.walled, "Walled"),
            ],
          ),
        ],
      ),
    );
  }

// Helper widget to display each feature with an icon
  Widget _buildFeatureItem(bool? feature, String featureName) {
    if (feature == true) {
      return Row(
        mainAxisSize:
            MainAxisSize.min, // Ensures row doesn't take too much space
        children: [
          const Icon(Icons.check, color: Colors.orange), // Icon for the feature
          const SizedBox(width: 5),
          Text(
            featureName,
            style: GoogleFonts.montserrat(
              color: Colors.black,
              fontSize: 14,
            ),
          ),
        ],
      );
    }
    return const SizedBox(); // Empty widget if the feature is false or null
  }

  Widget buildActionButtons(
      BuildContext context, bool isActivated, String flag, int houseId) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              BlocBuilder<ActivateBloc, ActivateState>(
                builder: (context, state) {
                  if (state is ActivateLoadingState) {
                    return const LoadingIndicator();
                  }

                  if (state is ActivateHouseSuccess) {
                    _handleActivationSuccess(context, state);
                  }

                  if (state is ActivateFailedState) {
                    _handleActivationFailed(context, state);
                  }

                  return _buildActionButton(
                      context, isActivated, flag, houseId);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleActivationSuccess(
      BuildContext context, ActivateHouseSuccess state) {
    if (state.isActivated) {
      isActivated = true;
    } else {
      _navigateToErrorPage(context, 'Failed to activate, contact admin');
      BlocProvider.of<ActivateBloc>(context).add(ActivationResetEvent());
    }
  }

  void _handleActivationFailed(
      BuildContext context, ActivateFailedState state) {
    if (state.message.contains("not registered")) {
      _navigateToErrorPage(context, 'Set up profile first');
    } else {
      _navigateToErrorPage(context, state.message ?? 'Failed to activate');
    }
    BlocProvider.of<ActivateBloc>(context).add(ActivationResetEvent());
  }

  void _navigateToErrorPage(BuildContext context, String errorMessage) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PropertyError(errorMessage: errorMessage)),
      );
    });
  }

  Widget _buildActionButton(
      BuildContext context, bool isActivated, String flag, int houseId) {
    if (flag == "actions") {
      return CustomElevateButton(
        name: "Actions",
        color: ColorConstants.yellow,
        onSubmit: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ActionsOptions(houseId: houseId)),
          );
        },
      );
    } else {
      return CustomElevateButton(
        name: isActivated ? 'APPOINTMENT' : 'ACTIVATE',
        color: ColorConstants.yellow,
        onSubmit: () {
          if (isActivated) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    Appointment(action: 'CREATE', houseId: houseId),
              ),
            );
          } else {
            BlocProvider.of<ActivateBloc>(context)
                .add(ActivateHouseEvent(houseId: houseId));
          }
        },
      );
    }
  }
}
