import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../utils/utils.dart';

class FAQs extends StatefulWidget {
  const FAQs({super.key});

  @override
  State<FAQs> createState() => _FAQsState();
}

class _FAQsState extends State<FAQs> {
  @override
  void initState() {
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: whiteColor,
        elevation: 0.2,
        iconTheme: const IconThemeData(color: blackColor),
      ),
      body: const WebView(
        javascriptMode: JavascriptMode.disabled,
        initialUrl: 'https://www.bechdeapp.com/faqs',
      ),
    );
  }
}
