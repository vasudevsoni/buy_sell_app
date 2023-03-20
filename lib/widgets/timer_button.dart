import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:buy_sell_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';

const int secondsPerUpdate = 1;
const String defaultSecondPostfix = 's';

class TimerButton extends StatefulWidget {
  final String label;
  final String secPostFix;
  final int timeOutInSeconds;
  final VoidCallback onPressed;
  final Color color;
  final Color disabledColor;
  final bool resetTimerOnPressed;

  const TimerButton({
    Key? key,
    required this.label,
    required this.onPressed,
    required this.timeOutInSeconds,
    this.secPostFix = defaultSecondPostfix,
    required this.color,
    this.resetTimerOnPressed = true,
    required this.disabledColor,
  }) : super(key: key);

  @override
  State<TimerButton> createState() => _TimerButtonState();
}

class _TimerButtonState extends State<TimerButton> {
  bool timeUpFlag = false;
  int timeCounter = 0;

  String get _timerText => '$timeCounter${widget.secPostFix}';

  @override
  void initState() {
    super.initState();
    timeCounter = widget.timeOutInSeconds;
    _startTimer();
  }

  _startTimer() {
    Timer(const Duration(seconds: secondsPerUpdate), () async {
      if (!mounted) return;
      setState(() {
        timeCounter--;
      });
      if (timeCounter != 0) {
        _startTimer();
        return;
      }
      timeUpFlag = true;
    });
  }

  void _onPressed() {
    if (!timeUpFlag) return;
    setState(() {
      timeUpFlag = false;
    });
    timeCounter = widget.timeOutInSeconds;
    widget.onPressed();
    if (widget.resetTimerOnPressed) {
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return timeUpFlag
        ? GFButton(
            onPressed: _onPressed,
            borderShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            color: widget.color,
            enableFeedback: true,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            size: GFSize.LARGE,
            animationDuration: const Duration(milliseconds: 100),
            child: AutoSizeText(
              widget.label,
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.interTight(
                color: whiteColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        : GFButton(
            onPressed: null,
            borderShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            color: widget.disabledColor,
            enableFeedback: true,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            size: GFSize.LARGE,
            animationDuration: const Duration(milliseconds: 100),
            child: AutoSizeText(
              'Please wait for $_timerText',
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.interTight(
                color: blackColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
  }
}
