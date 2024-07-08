import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:native_interface/proto/hfs_msg.pb.dart';
import 'package:provider/provider.dart';

import '../../../ffi/ffi.io.dart';
import '../../root/controllers/root_controller.dart';

class HfsButton extends StatefulWidget {
  const HfsButton({
    Key? key,
  }) : super(key: key);

  @override
  HfsButtonState createState() => HfsButtonState();
}

class HfsButtonState extends State<HfsButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    _lottieController.duration = const Duration(milliseconds: 200);
    if (context.read<RootController>().hfsStatus == HfsStatus.Running &&
        !_lottieController.isAnimating) {
      _lottieController.value = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 60,
        height: 60,
        child: FilledButton.tonal(
            onPressed: () async {
              if (_lottieController.isAnimating) {
                return;
              }
              if (_lottieController.value > 0) {
                await systemApi.stopHfs();
                _lottieController.reverse();
                return;
              }
              await systemApi.runHfs();
              _lottieController.forward();
            },
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  // Change your radius here
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              padding: MaterialStateProperty.all(const EdgeInsets.all(2)),
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
                      color: context.select<RootController,Color>((value) {
                        switch (value.hfsStatus) {
                          case  HfsStatus.Running:
                            return Colors.transparent;
                          default:
                            return Colors.transparent;
                        }
                      }),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Container(),
                  ),
                )
              ],
            )));
  }
}
