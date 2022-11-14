import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:intl/intl.dart';

import '/services/firebase_services.dart';
import '/utils/utils.dart';

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
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                'Something has gone wrong. Please try again',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          );
        }
        if (snapshot.hasData && snapshot.data!.size == 0) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  'No messages here yet!',
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                'Start by sending a Hi',
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(15.0),
            child: Center(
              child: SpinKitFadingCircle(
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
                snapshot.data!.docs[index]['isOffer'] == true
                    ? BubbleNormal(
                        bubbleRadius: 5,
                        text: snapshot.data!.docs[index]['message'],
                        color: redColor,
                        isSender: sentBy == me ? true : false,
                        tail: true,
                        textStyle: const TextStyle(
                          color: whiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : BubbleNormal(
                        bubbleRadius: 5,
                        text: snapshot.data!.docs[index]['message'],
                        color: sentBy == me ? blueColor : greyColor,
                        isSender: sentBy == me ? true : false,
                        tail: true,
                        textStyle: sentBy == me
                            ? const TextStyle(
                                color: whiteColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              )
                            : const TextStyle(
                                color: blackColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
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
                                style: const TextStyle(
                                  color: blackColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(
                                width: 3,
                              ),
                              Text(
                                date,
                                style: const TextStyle(
                                  color: fadedColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                date,
                                style: const TextStyle(
                                  color: fadedColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(
                                width: 3,
                              ),
                              Text(
                                time,
                                style: const TextStyle(
                                  color: blackColor,
                                  fontSize: 10,
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
