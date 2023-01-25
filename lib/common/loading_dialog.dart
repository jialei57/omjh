import 'package:flutter/material.dart';
import 'dart:math' as math;

class LoadingDialog {
  BuildContext context;
  var isShow = false;
  AnimationController controller;

  LoadingDialog(this.context, this.controller);

  void show() {
    isShow = true;
    showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    child: SizedBox(
                        width: 60,
                        height: 60,
                        child: _buildLoadingAnimation()))))
        .then((value) => isShow = false);
  }

  Widget _buildLoadingAnimation() {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) {
        return Transform.rotate(
          angle: controller.value * 2 * math.pi,
          child: child,
        );
      },
      child: const Image(
        image: AssetImage('assets/image/ic_taiji.png'),
        width: 60,
        height: 60,
      ),
    );
  }

  void dismiss() {
    if (!isShow) return;
    isShow = false;
    Navigator.pop(context);
  }
}
