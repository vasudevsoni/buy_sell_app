import 'package:buy_sell_app/services/firebase_services.dart';
import 'package:buy_sell_app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../utils/utils.dart';

class UserRatingScreen extends StatefulWidget {
  final String name;
  final String userId;
  const UserRatingScreen({
    super.key,
    required this.name,
    required this.userId,
  });

  @override
  State<UserRatingScreen> createState() => _UserRatingScreenState();
}

class _UserRatingScreenState extends State<UserRatingScreen> {
  final _services = FirebaseServices();
  bool isStar1Selected = false;
  bool isStar2Selected = false;
  bool isStar3Selected = false;
  bool isStar4Selected = false;
  bool isStar5Selected = false;
  int selectedStars = 0;
  String feedbackText = '';
  Color textColor = blackColor;

  select1Star() {
    setState(() {
      selectedStars = 1;
      isStar1Selected = true;
      isStar2Selected = false;
      isStar3Selected = false;
      isStar4Selected = false;
      isStar5Selected = false;
      feedbackText = 'Poor • 1 star';
      textColor = redColor;
    });
  }

  select2Star() {
    setState(() {
      selectedStars = 2;
      isStar1Selected = true;
      isStar2Selected = true;
      isStar3Selected = false;
      isStar4Selected = false;
      isStar5Selected = false;
      feedbackText = 'Not so Great • 2 stars';
      textColor = Colors.orange;
    });
  }

  select3Star() {
    setState(() {
      selectedStars = 3;
      isStar1Selected = true;
      isStar2Selected = true;
      isStar3Selected = true;
      isStar4Selected = false;
      isStar5Selected = false;
      feedbackText = 'Normal • 3 stars';
      textColor = blueColor;
    });
  }

  select4Star() {
    setState(() {
      selectedStars = 4;
      isStar1Selected = true;
      isStar2Selected = true;
      isStar3Selected = true;
      isStar4Selected = true;
      isStar5Selected = false;
      feedbackText = 'Good • 4 stars';
      textColor = Colors.lightGreen;
    });
  }

  select5Star() {
    setState(() {
      selectedStars = 5;
      isStar1Selected = true;
      isStar2Selected = true;
      isStar3Selected = true;
      isStar4Selected = true;
      isStar5Selected = true;
      feedbackText = 'Great • 5 stars';
      textColor = greenColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: blackColor),
        centerTitle: true,
        title: Text(
          'Rate ${widget.name}',
          style: GoogleFonts.interTight(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rate this user',
              maxLines: 1,
              softWrap: true,
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.interTight(
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: blueColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => select1Star(),
                    child: Icon(
                      MdiIcons.star,
                      color: isStar1Selected ? whiteColor : blackColor,
                      size: 30,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => select2Star(),
                    child: Icon(
                      MdiIcons.star,
                      color: isStar2Selected ? whiteColor : blackColor,
                      size: 30,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => select3Star(),
                    child: Icon(
                      MdiIcons.star,
                      color: isStar3Selected ? whiteColor : blackColor,
                      size: 30,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => select4Star(),
                    child: Icon(
                      MdiIcons.star,
                      color: isStar4Selected ? whiteColor : blackColor,
                      size: 30,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => select5Star(),
                    child: Icon(
                      MdiIcons.star,
                      color: isStar5Selected ? whiteColor : blackColor,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Center(
              child: Text(
                feedbackText,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  fontSize: 30,
                ),
              ),
            ),
            const Spacer(),
            CustomButton(
              text: 'Submit Rating',
              onPressed: selectedStars == 0
                  ? () => showSnackBar(
                        content: 'Please select stars to rate this user',
                        color: redColor,
                      )
                  : () => _services.rateUser(
                        stars: selectedStars,
                        userId: widget.userId,
                      ),
              isFullWidth: true,
              icon: MdiIcons.checkOutline,
              borderColor: blueColor,
              bgColor: blueColor,
              textIconColor: whiteColor,
            ),
          ],
        ),
      ),
    );
  }
}