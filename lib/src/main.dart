import 'dart:math';
import 'package:candlesticks/src/constant/intervals.dart';
import 'package:candlesticks/src/models/candle.dart';
import 'package:candlesticks/src/theme/color_palette.dart';
import 'package:candlesticks/src/widgets/chart.dart';
import 'package:candlesticks/src/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'models/candle.dart';

/// StatefulWidget that holds Chart's State (index of
/// current position and candles width).
class Candlesticks extends StatefulWidget {
  final List<Candle> candles;

  /// callback calls when user changes interval
  final Future<void> Function(String) onIntervalChange;

  final String interval;

  Candlesticks({
    required this.candles,
    required this.onIntervalChange,
    required this.interval,
  });

  @override
  _CandlesticksState createState() => _CandlesticksState();
}

/// [Candlesticks] state
class _CandlesticksState extends State<Candlesticks> {
  /// index of the newest candle to be displayed
  /// changes when user scrolls along the chart
  int index = -10;
  ScrollController scrollController = new ScrollController();

  /// candleWidth controls the width of the single candles.
  ///  range: [2...10]
  double candleWidth = 6;

  bool showIntervals = false;

  @override
  Widget build(BuildContext context) {
    if (widget.candles.length == 0)
      return Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    return Column(
      children: [
        Container(
          color: ColorPalette.barColor,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Row(
              children: [
                CustomButton(
                  onPressed: () {
                    setState(() {
                      candleWidth -= 2;
                      candleWidth = max(candleWidth, 2);
                    });
                  },
                  child: Icon(
                    Icons.remove,
                    color: ColorPalette.grayColor,
                  ),
                ),
                CustomButton(
                  onPressed: () {
                    setState(() {
                      candleWidth += 2;
                      candleWidth = min(candleWidth, 10);
                    });
                  },
                  child: Icon(
                    Icons.add,
                    color: ColorPalette.grayColor,
                  ),
                ),
                CustomButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Center(
                          child: Container(
                            width: 200,
                            color: ColorPalette.digalogColor,
                            child: Wrap(
                              children: intervals
                                  .map(
                                    (e) => Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CustomButton(
                                        width: 50,
                                        color: ColorPalette.lightGold,
                                        child: Text(
                                          e,
                                          style: TextStyle(
                                            color: ColorPalette.gold,
                                          ),
                                        ),
                                        onPressed: () {
                                          widget.onIntervalChange(e);
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Text(
                    widget.interval,
                    style: TextStyle(
                      color: ColorPalette.grayColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: TweenAnimationBuilder(
            tween: Tween(begin: 6.toDouble(), end: candleWidth),
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOutCirc,
            builder: (_, width, __) {
              return Chart(
                onScaleUpdate: (double scale) {
                  setState(() {
                    candleWidth *= scale;
                    candleWidth = min(candleWidth, 10);
                    candleWidth = max(candleWidth, 2);
                    candleWidth.toInt();
                  });
                },
                scrollController: scrollController,
                onHorizontalDragUpdate: (double x) {
                  if (x.abs() < 2) return;
                  setState(() {
                    index += x ~/ 2;
                    index = max(index, -10);
                    index = min(index, widget.candles.length - 1);
                  });
                  scrollController.jumpTo(index * candleWidth);
                },
                candleWidth: width as double,
                candles: widget.candles,
                index: index,
              );
            },
          ),
        ),
      ],
    );
  }
}
