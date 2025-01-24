import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imba/bloc/upload/upload_event.dart';
import 'package:imba/bloc/upload/upload_state.dart';
import 'package:imba/bloc/user/user_bloc.dart';
import 'package:imba/bloc/user/user_event.dart';
import 'package:imba/ui/layouts/home_layout.dart';
import 'package:imba/ui/screens/search_page.dart';
import 'package:imba/ui/screens/upload_details.dart';

import '../../bloc/upload/upload_bloc.dart';
import '../../utilities/constants.dart';
import '../widgets/custom_elevated_button.dart';
import '../widgets/custom_home_drawer.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/logo.dart';
import '../widgets/opaque_container.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late UploadBloc uploadBloc;
  late UserBloc userBloc;
  List<String> types = [];
  List<String> classifications = [];
  var isSuccess = false;

  @override
  void initState() {
    BlocProvider.of<UserBloc>(context).add(GetUserEvent());
    uploadBloc = BlocProvider.of<UploadBloc>(context);
    uploadBloc.add(FetchTypesEvent());
    uploadBloc.add(FetchClassificationsEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return HomeLayout(
      hasBack: false,
      isSuccess: isSuccess,
      child: Center(
        child: Column(
          children: [
           
            // const Logo(),
            Container(
              // height: 150,
              // width: 200,
              //30 % of the screen width
              width: MediaQuery.of(context).size.width * 0.3,
              height: MediaQuery.of(context).size.width * 0.3,

              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/home_icon.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "IMBA",
              style: TextStyle(
                backgroundColor: Colors.transparent,
                fontFamily: 'Antreas',
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: Colors.orange
              ),
            ),
          
            // const CustomOpaqueContainer(
            //   name: "NYUMBA",
            //   googleFontStyle: TextStyle(
            //     backgroundColor: Colors.transparent,
            //     fontFamily: 'Antreas',
            //     fontSize: 80,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "Welcome to Imba, your one-stop platform for uploading and searching for houses to rent. Get started by uploading your property or searching for your dream home.",
                textAlign: TextAlign.center,
                
                style: GoogleFonts.montserrat(color: Colors.black,fontSize:screenWidth * 0.07 , ),
              ),
            ),
            const Spacer(),
            Visibility(
              visible: true,
              child: BlocListener<UploadBloc, UploadState>(
                listener: (context, state) {
                  if (state is TypesSuccessState) {
                    types = state.types.types;
                  }
        
                  if (state is ClassificationsSuccessState) {
                    classifications = state.classifications.classifications;
                    setState(() {
                      isSuccess = true;
                    });
                  }
                },
                child: BlocBuilder<UploadBloc, UploadState>(
                  builder: (context, state) {
                    if (state is UploadLoadingState) {
                      return const LoadingIndicator();
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            Visibility(
              visible: isSuccess,
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 60,
                    child: CustomElevateButton(
                      name: 'Upload',
                      isOutline: true,
                      color: Colors.orange,
                      onSubmit: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => UploadDetails(
                              types: types,
                              classifications: classifications,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    //80% of the screen width
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 60,
                    child: CustomElevateButton(
                      name: 'Search',
                      color: Colors.orange,
                      onSubmit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Search(
                              types: types,
                              classifications: classifications,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
