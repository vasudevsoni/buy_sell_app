import 'package:flutter/material.dart';

class ChatsScreen extends StatelessWidget {
  static const String routeName = '/chats-screen';
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Text('Chats'),
      ),
    );
  }
}
