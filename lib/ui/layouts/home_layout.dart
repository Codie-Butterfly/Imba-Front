import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imba/ui/widgets/custom_home_drawer.dart';

class HomeLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final bool isSuccess;
  final List<Widget> actions;
  final bool hasBack;

  const HomeLayout({
    Key? key,
    required this.child,
    this.title = 'Home',
    this.isSuccess = false,
    this.actions = const [],
    required this.hasBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          leading: Builder(
            builder: (context) => hasBack
                ? InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      height: 24,
                      width: 24,
                      child: const Icon(Icons.arrow_back_ios, color: Colors.black),
                    ),
                  )
                : IconButton(
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    icon:  const Icon(Icons.menu, color: Colors.black, size: 35),
                  ),
          ),
          title: Text(
            title,
            style: GoogleFonts.montserrat(color: Colors.black, fontSize: 30),
          ),
          actions: actions,
        ),
      ),
      backgroundColor: Colors.white,
      drawer: const CustomHomeDrawer(),
      body: SafeArea(
        child: child,
      ),
    );
  }
}
