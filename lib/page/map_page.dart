import 'dart:math';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omjh/common/shared.dart';
import 'package:omjh/common/theme_style.dart';
import 'package:omjh/entity/spot.dart';

class MapDialog {
  BuildContext context;
  final spotWidth = 90.0;
  final spotHeight = 60.0;
  final padding = 10.0;
  final spacing = 50.0;
  final shared = Get.put(Shared());
  final viewTransformationController = TransformationController();
  int minX = 0, minY = 0, maxX = 0, maxY = 0;
  double width = 0, height = 0;
  List<Spot> currentMapSpots = [];
  final zoomFactor = 0.8;

  MapDialog(this.context);

  void showCurrentMap() {
    currentMapSpots =
        shared.maps.where((e) => e.city == shared.currentMap!.city).toList();
    minX = currentMapSpots.reduce((a, b) => a.getX() < b.getX() ? a : b).getX();
    maxX = currentMapSpots.reduce((a, b) => a.getX() > b.getX() ? a : b).getX();
    minY = currentMapSpots.reduce((a, b) => a.getY() < b.getY() ? a : b).getY();
    maxY = currentMapSpots.reduce((a, b) => a.getY() > b.getY() ? a : b).getY();

    width = (maxX - minX + 1) * (spotWidth + spacing) - spacing + padding;
    height = (maxY - minY + 1) * (spotHeight + spacing) - spacing + padding;
    viewTransformationController.value.setEntry(0, 0, zoomFactor);
    viewTransformationController.value.setEntry(1, 1, zoomFactor);
    viewTransformationController.value.setEntry(2, 2, zoomFactor);

    final screenWidth = MediaQuery.of(context).size.width - 2 - padding * 2;
    final screenHeight = shared.contentHeight * 3 / 4 - 32 - padding * 2;

    final maxXTranslate = width * zoomFactor - screenWidth;
    final maxYTranslate = height * zoomFactor - screenHeight;
    final xTranslate = (spotWidth + spacing) *
            (shared.currentMap!.getX() - minX) *
            zoomFactor -
        screenWidth / 2 +
        spotWidth / 2 * zoomFactor;
    var yTranslate = (spotHeight + spacing) *
            (shared.currentMap!.getY() - minY) *
            zoomFactor -
        screenHeight / 2 +
        spotHeight / 2 * zoomFactor;

    viewTransformationController.value
        .setEntry(0, 3, -(max(min(maxXTranslate, xTranslate), 0.0)));
    viewTransformationController.value
        .setEntry(1, 3, -(max(min(maxYTranslate, yTranslate), 0.0)));

    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) =>
            StatefulBuilder(builder: (context, setState) {
              return Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding:
                      EdgeInsets.fromLTRB(1, 0, 1, shared.contentHeight / 4),
                  child: Container(
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(180, 255, 255, 255),
                          border:
                              Border.all(color: ThemeStyle.bgColor, width: 1.5),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8))),
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(padding),
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Text(shared.currentMap!.city,
                              style:
                                  ThemeStyle.textStyle.copyWith(fontSize: 20)),
                          Container(
                            margin: const EdgeInsets.only(top: 32),
                            // color: Colors.amber,
                            child: InteractiveViewer(
                                transformationController:
                                    viewTransformationController,
                                minScale: 0.5,
                                maxScale: 1.0,
                                constrained: false,
                                child: _buildCurrentMapSpots()),
                          ),
                        ],
                      )));
            }));
  }

  Widget _buildCurrentMapSpots() {
    List<Widget> spots = [];
    for (var e in currentMapSpots) {
      List<Widget> ws = _buildSpot(e);
      if (ws.isNotEmpty) {
        spots.addAll(ws);
      }
    }
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: spots,
      ),
    );
  }

  List<Widget> _buildSpot(Spot spot) {
    List<Widget> result = [];

    if (spot.getType() != 'maze') {
      Widget content;
      switch (spot.getType()) {
        case 'maze-0':
          content = DottedBorder(
            color: ThemeStyle.bgColor,
            dashPattern: const [8, 6],
            strokeWidth: 3,
            child: Container(
              color: Colors.white,
              width: spotWidth,
              height: spotHeight,
              child: Center(
                  child: Text(spot.name,
                      style: ThemeStyle.textStyle.copyWith(fontSize: 16))),
            ),
          );
          break;
        default:
          content = Container(
            width: spotWidth,
            height: spotHeight,
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: ThemeStyle.bgColor, width: 2)),
            child: Center(
                child: Text(spot.name,
                    style: ThemeStyle.textStyle.copyWith(fontSize: 16))),
          );
      }
      result.add(Positioned(
          left: (spotWidth + spacing) * (spot.getX() - minX),
          top: (spotHeight + spacing) * (spot.getY() - minY),
          child: content));
    }

    if (spot.getType() != 'maze' && spot.getType() != 'maze-0') {
      if (spot.left != null) {
        Spot leftSpot = findLeftSpot(spot)!;
        if (leftSpot.getType() == 'maze-0' || leftSpot.getType() == 'maze') {
          result.add(Positioned(
              left: (spotWidth + spacing) * (spot.getX() - minX) - spacing + 2,
              top: (spotHeight + spacing) * (spot.getY() - minY) +
                  spotHeight / 2,
              child: Container(
                width: spacing - 2,
                height: 2,
                color: ThemeStyle.bgColor,
              )));
        }
      }

      if (spot.top != null) {
        Spot topSpot = findTopSpot(spot)!;
        if (topSpot.getType() == 'maze-0' || topSpot.getType() == 'maze') {
          result.add(Positioned(
              left:
                  (spotWidth + spacing) * (spot.getX() - minX) + spotWidth / 2,
              top: (spotHeight + spacing) * (spot.getY() - minY) - spacing + 2,
              child: Container(
                width: 2,
                height: spacing - 2,
                color: ThemeStyle.bgColor,
              )));
        }
      }

      if (spot.right != null) {
        result.add(Positioned(
            left: (spotWidth + spacing) * (spot.getX() - minX) + spotWidth,
            top: (spotHeight + spacing) * (spot.getY() - minY) + spotHeight / 2,
            child: Container(
              width: spacing,
              height: 2,
              color: ThemeStyle.bgColor,
            )));
      }

      if (spot.bottom != null) {
        result.add(Positioned(
            left: (spotWidth + spacing) * (spot.getX() - minX) + spotWidth / 2,
            top: (spotHeight + spacing) * (spot.getY() - minY) + spotHeight,
            child: Container(
              width: 2,
              height: spacing,
              color: ThemeStyle.bgColor,
            )));
      }
    }

    if (spot == shared.currentMap) {
      result.add(Positioned(
          left: (spotWidth + spacing) * (spot.getX() - minX) + spotWidth - 25,
          top: (spotHeight + spacing) * (spot.getY() - minY) + 4,
          child: const Icon(Icons.emoji_people)));
    }

    return result;
  }

  Spot? findLeftSpot(Spot spot) {
    if (shared.maps.isEmpty) {
      return null;
    }

    if (spot.left == null) {
      return null;
    }

    return shared.maps[spot.left! - 1];
  }

  Spot? findTopSpot(Spot spot) {
    if (shared.maps.isEmpty) {
      return null;
    }

    if (spot.top == null) {
      return null;
    }

    return shared.maps[spot.top! - 1];
  }
}
