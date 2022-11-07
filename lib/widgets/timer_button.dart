import 'package:auto_size_text/auto_size_text.dart';
import 'package:buy_sell_app/utils/utils.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'dart:async';

import 'package:google_fonts/google_fonts.dart';

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
      } else {
        timeUpFlag = true;
      }
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
    return timeUpFlag
        ? GestureDetector(
            onTap: _onPressed,
            child: Container(
              height: 45,
              width: MediaQuery.of(context).size.width,
              decoration: ShapeDecoration(
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: widget.color,
              ),
              child: Center(
                child: AutoSizeText(
                  widget.label,
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: whiteColor,
                  ),
                ),
              ),
            ),
          )
        : GestureDetector(
            onTap: null,
            child: Container(
              height: 45,
              width: MediaQuery.of(context).size.width,
              decoration: ShapeDecoration(
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: widget.disabledColor,
              ),
              child: Center(
                child: AutoSizeText(
                  'Please wait for $_timerText',
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: blackColor,
                  ),
                ),
              ),
            ),
          );
  }
}
