import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:buy_sell_app/utils/utils.dart';
import 'package:flutter/material.dart';

const int aSec = 1;
const String _secPostFix = 's';

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
    this.secPostFix = _secPostFix,
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
    _timerUpdate();
  }

  _timerUpdate() {
    Timer(const Duration(seconds: aSec), () async {
      if (mounted) {
        setState(() {
          timeCounter--;
        });
      }
      if (timeCounter != 0) {
        _timerUpdate();
        return;
      }
      timeUpFlag = true;
    });
  }

  _onPressed() {
    if (timeUpFlag) {
      setState(() {
        timeUpFlag = false;
      });
      timeCounter = widget.timeOutInSeconds;
      widget.onPressed();
      if (widget.resetTimerOnPressed) {
        _timerUpdate();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return timeUpFlag
        ? ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.color,
              elevation: 0,
              splashFactory: InkRipple.splashFactory,
              enableFeedback: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              fixedSize: Size(size.width, 45),
            ),
            onPressed: _onPressed,
            child: AutoSizeText(
              widget.label,
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: whiteColor,
                fontWeight: FontWeight.w600,
                fontSize: 14.5,
              ),
            ),
          )
        : ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.disabledColor,
              elevation: 0,
              splashFactory: InkRipple.splashFactory,
              enableFeedback: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              fixedSize: Size(size.width, 45),
            ),
            onPressed: null,
            child: AutoSizeText(
              'Please wait for $_timerText',
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: whiteColor,
                fontWeight: FontWeight.w600,
                fontSize: 14.5,
              ),
            ),
          );
  }
}
