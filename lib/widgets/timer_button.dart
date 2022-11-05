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
        ? SizedBox(
            height: 45,
            width: MediaQuery.of(context).size.width,
            child: NeumorphicButton(
              onPressed: _onPressed,
              style: NeumorphicStyle(
                lightSource: LightSource.top,
                shape: NeumorphicShape.convex,
                depth: 0,
                intensity: 0,
                border: NeumorphicBorder(
                  color: widget.disabledColor,
                  width: 1,
                ),
                boxShape: NeumorphicBoxShape.roundRect(
                  BorderRadius.circular(5),
                ),
                color: widget.color,
              ),
              provideHapticFeedback: true,
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
        : SizedBox(
            height: 45,
            width: MediaQuery.of(context).size.width,
            child: NeumorphicButton(
              onPressed: null,
              style: NeumorphicStyle(
                lightSource: LightSource.top,
                shape: NeumorphicShape.convex,
                depth: 0,
                intensity: 0,
                border: NeumorphicBorder(
                  color: widget.disabledColor,
                  width: 1,
                ),
                boxShape: NeumorphicBoxShape.roundRect(
                  BorderRadius.circular(5),
                ),
                color: widget.disabledColor,
              ),
              provideHapticFeedback: true,
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
