import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/utils.dart';

class ChatsScreen extends StatelessWidget {
  static const String routeName = '/chats-screen';
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0.2,
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
          title: Text(
            'My Chats',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          bottom: TabBar(
            indicatorColor: blueColor,
            indicatorWeight: 4,
            isScrollable: false,
            tabs: [
              Tab(
                child: Text(
                  'Buying',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: blueColor,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Selling',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: blueColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: const SafeArea(
          child: Text('Chats'),
        ),
      ),
    );
  }
}
