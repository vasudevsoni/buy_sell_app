import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:buy_sell_app/services/firebase_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../utils/utils.dart';

class ChatStream extends StatefulWidget {
  final String chatRoomId;
  const ChatStream({
    super.key,
    required this.chatRoomId,
  });

  @override
  State<ChatStream> createState() => _ChatStreamState();
}

class _ChatStreamState extends State<ChatStream> {
  final FirebaseServices _services = FirebaseServices();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _services.chats
          .doc(widget.chatRoomId)
          .collection('messages')
          .orderBy('time')
          .snapshots(),
      builder: (
        BuildContext context,
        AsyncSnapshot<QuerySnapshot> snapshot,
      ) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Some error occurred. Please try again',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          );
        } else if (snapshot.hasData && snapshot.data!.size == 0) {
          return Padding(
            padding: const EdgeInsets.all(15),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No messages here.\nStart by sending a \'hi\'.',
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  const Icon(
                    Iconsax.message_text4,
                    color: blueColor,
                    size: 20,
                  ),
                ],
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(15.0),
            child: Center(
              child: SpinKitFadingCube(
                color: lightBlackColor,
                size: 20,
                duration: Duration(milliseconds: 1000),
              ),
            ),
          );
        }
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 15),
          itemBuilder: (context, index) {
            var date = DateFormat.yMMMd().format(
              DateTime.fromMicrosecondsSinceEpoch(
                snapshot.data!.docs[index]['time'],
              ),
            );
            var time = DateFormat.jm().format(
              DateTime.fromMicrosecondsSinceEpoch(
                snapshot.data!.docs[index]['time'],
              ),
            );
            String sentBy = snapshot.data!.docs[index]['sentBy'];
            String me = _services.user!.uid;
            return Column(
              children: [
                BubbleSpecialThree(
                  text: snapshot.data!.docs[index]['message'],
                  color: sentBy == me ? blueColor : greyColor,
                  isSender: sentBy == me ? true : false,
                  tail: true,
                  textStyle: sentBy == me
                      ? GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        )
                      : GoogleFonts.poppins(
                          color: blackColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                ),
                Align(
                  alignment: sentBy == me
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: sentBy == me
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                time,
                                style: GoogleFonts.poppins(
                                  color: blackColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(
                                width: 3,
                              ),
                              Text(
                                date,
                                style: GoogleFonts.poppins(
                                  color: fadedColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                date,
                                style: GoogleFonts.poppins(
                                  color: fadedColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(
                                width: 3,
                              ),
                              Text(
                                time,
                                style: GoogleFonts.poppins(
                                  color: blackColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
              ],
            );
          },
          itemCount: snapshot.data!.docs.length,
        );
      },
    );
  }
}
