import 'package:cinarium/screens/http/controllers/http_controller.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../root/controllers/root_controller.dart';

class HttpButton extends StatefulWidget {
  const HttpButton({
    super.key,
  });

  @override
  HttpButtonState createState() => HttpButtonState();
}

class HttpButtonState extends State<HttpButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    _lottieController.duration = const Duration(milliseconds: 200);
    if (context
        .read<RootController>()
        .httpStatus &&
        !_lottieController.isAnimating) {
      _lottieController.value = 1;
    }
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(HttpButton oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    context.select<HttpController, bool>((value) {
      if (value.httpStatus) {
        _lottieController.forward();
      }else{
        _lottieController.reverse();
      }
      return value.httpStatus;
    });
    return SizedBox(
        width: 60,
        height: 60,
        child: FilledButton.tonal(
            onPressed: () async {
             context.read<HttpController>().switchHttp();
            },
            style: ButtonStyle(
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  // Change your radius here
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              padding: WidgetStateProperty.all(const EdgeInsets.all(2)),
            ),
            child: Stack(
              children: [
                Lottie.asset(
                  "assets/lottie/system-solid-26-play.json",
                  repeat: false,
                  animate: false,
                  reverse: false,
                  controller: _lottieController,
                  frameRate: FrameRate.max,
                  width: 30,
                  height: 30,
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Container(),
                  ),
                )
              ],
            )));
  }
}
