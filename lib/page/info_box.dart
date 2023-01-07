import 'package:flutter/material.dart';
import 'package:omjh/common/shared.dart';
import 'package:omjh/common/theme_style.dart';
import 'package:get/get.dart';
import 'package:omjh/entity/spot.dart';

enum MoveDirection { up, down, left, right, none }

class InfoBox extends StatefulWidget {
  const InfoBox({super.key});

  @override
  State<InfoBox> createState() => _InfoBoxState();
}

class _InfoBoxState extends State<InfoBox> with TickerProviderStateMixin {
  final spotWidth = 90.0;
  final spotHeight = 30.0;
  final spotVerticalPadding = 10;
  final spotHorizontalPadding = 20;
  final boxHeight = 130.0;
  var controlLeftPadding = 0.0;
  var controlTopPadding = 0.0;
  final shared = Get.put(Shared());
  late final AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;
  var moveDirection = MoveDirection.none;
  Spot? nextSpot;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reset();
        setState(() {
          shared.currentMap = nextSpot;
        });
      }
    });
    setAnimation();
  }

  void setAnimation() {
    Tween<Offset> offset =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, 0.0));

    switch (moveDirection) {
      case MoveDirection.up:
        offset = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0.0, -0.3),
        );
        break;
      case MoveDirection.down:
        offset = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0.0, 0.3),
        );
        break;
      case MoveDirection.left:
        offset = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-1.0, 0.0),
        );
        break;
      case MoveDirection.right:
        offset = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(1.0, 0.0),
        );
        break;
      case MoveDirection.none:
        offset = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0.0, 0.0),
        );
        break;
    }

    _offsetAnimation = offset.animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    controlLeftPadding =
        (screenWidth - 3 * spotWidth - 2 * spotHorizontalPadding) / 2;
    controlTopPadding =
        (boxHeight - 3 * spotHeight - 2 * spotVerticalPadding) / 2;
    return Column(
      children: [
        Expanded(
            child: Row(
          children: [
            Expanded(
                child: Column(
              children: [_buildInfo()],
            )),
            _buildPlayers()
          ],
        )),
        Column(children: [_buildControlBox(), _buildNPCs()])
      ],
    );
  }

  Widget _buildInfo() {
    return Container(
        height: 100,
        width: double.infinity,
        margin: const EdgeInsets.all(4.0),
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
            border: Border.all(color: ThemeStyle.bgColor, width: 1.5),
            borderRadius: const BorderRadius.all(Radius.circular(4))),
        child: Text(shared.currentMap?.description ?? '',
            style: ThemeStyle.textStyle.copyWith(fontSize: 16)));
  }

  Widget _buildPlayers() {
    return Container(
      width: spotWidth + 8,
      height: double.infinity,
      decoration: const BoxDecoration(
          border:
              Border(left: BorderSide(width: 1.5, color: ThemeStyle.bgColor))),
      child: const SizedBox.shrink(),
    );
  }

  Widget _buildNPCs() {
    return SizedBox(
      height: 36,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: Row(
          children: [
            Text('there_are'.tr,
                style: ThemeStyle.textStyle.copyWith(fontSize: 16)),
            // _buildSpot()
          ],
        ),
      ),
    );
  }

  Widget _buildSpot(Spot? spot, MoveDirection direction,
      {bool isCurrent = false}) {
    if (spot == null) {
      return const SizedBox.shrink();
    }
    return SlideTransition(
      position: _offsetAnimation,
      child: GestureDetector(
        onTap: () {
          if (!isCurrent) {
            shared.currentCharacter!.map = spot.id;

            _animationController.forward(from: 0.1);
            nextSpot = spot;
            moveDirection = direction;
            setAnimation();
            _animationController.forward();
          }
        },
        child: Container(
          width: spotWidth,
          height: spotHeight,
          decoration: BoxDecoration(
              color: isCurrent ? Colors.grey : Colors.white,
              border: Border.all(color: ThemeStyle.bgColor, width: 2)),
          child: Center(
              child: Text(spot.name,
                  style: isCurrent
                      ? ThemeStyle.textStyle
                          .copyWith(fontSize: 16, color: Colors.white)
                      : ThemeStyle.textStyle.copyWith(fontSize: 16))),
        ),
      ),
    );
  }

  Spot? findLeftSpot() {
     if (shared.maps.isEmpty) {
      return null;
    }

    if (shared.currentMap?.left == null) {
      return null;
    }

    return shared.maps[shared.currentMap!.left!-1];
  }

  Spot? findRightSpot() {
    if (shared.maps.isEmpty) {
      return null;
    }

    if (shared.currentMap?.right == null) {
      return null;
    }

    return shared.maps[shared.currentMap!.right!-1];
  }

  Spot? findTopSpot() {
    if (shared.maps.isEmpty) {
      return null;
    }

    if (shared.currentMap?.top == null) {
      return null;
    }

    return shared.maps[shared.currentMap!.top!-1];
  }

  Spot? findBottomSpot() {
    if (shared.maps.isEmpty) {
      return null;
    }

    if (shared.currentMap?.bottom == null) {
      return null;
    }

    return shared.maps[shared.currentMap!.bottom!-1];
  }

  Widget _buildControlBox() {
    return Container(
        height: boxHeight,
        width: double.infinity,
        decoration: const BoxDecoration(
            border:
                Border(top: BorderSide(width: 1.5, color: ThemeStyle.bgColor))),
        child: Stack(
          children: [
            Positioned(
                top: controlTopPadding,
                left: 10,
                child: Text(shared.currentMap?.city ?? '',
                    style: ThemeStyle.textStyle.copyWith(fontSize: 18))),
            Positioned(
              //left
              top: controlTopPadding + spotHeight + spotVerticalPadding,
              left: controlLeftPadding,
              child: _buildSpot(findLeftSpot(), MoveDirection.right),
            ),
            Positioned(
              //top
              top: controlTopPadding,
              left: controlLeftPadding + spotHorizontalPadding + spotWidth,
              child: _buildSpot(findTopSpot(), MoveDirection.down),
            ),
            Positioned(
              //middle
              top: controlTopPadding + spotHeight + spotVerticalPadding,
              left: controlLeftPadding + spotHorizontalPadding + spotWidth,
              child: _buildSpot(shared.currentMap, MoveDirection.none,
                  isCurrent: true),
            ),
            Positioned(
              //right
              top: controlTopPadding + spotHeight + spotVerticalPadding,
              left: controlLeftPadding +
                  spotHorizontalPadding * 2 +
                  spotWidth * 2,
              child: _buildSpot(findRightSpot(), MoveDirection.left),
            ),
            Positioned(
              //bottom
              top: controlTopPadding + spotHeight * 2 + spotVerticalPadding * 2,
              left: controlLeftPadding + spotHorizontalPadding + spotWidth,
              child: _buildSpot(findBottomSpot(), MoveDirection.up),
            )
          ],
        ));
  }
}
