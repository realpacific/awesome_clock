import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

abstract class HandManager {
  final List<int> values;
  final ScrollController controller;
  int _counter = 1;
  int _duplicationCount = 5;
  final DateFormat dateFormat;
  int _previousValue = 0;

  HandManager(this.values, this.controller, this.dateFormat);

  int get duplicationCount => _duplicationCount;

  calculateIndex(DateTime dateTime) {
    final format = dateFormat.format(dateTime);
    final handTime = int.parse(format);
    final indexOfCurrentHand = values.indexOf(handTime);
    final newPosition = indexOfCurrentHand + values.length * _counter;
    if (_previousValue == handTime) {
      return newPosition;
    }
    _previousValue = handTime;
    // If the current hand time value is equal to the max possible value of the hand i.e the last element of [values], then switch to new iteration;
    if (handTime == values.last) {
      _counter++;
      print("At last: Counter:" + _counter.toString());
    }
    // Reset the [_counter] since there is only one set of the hand values remaining, and we have to leave one set of hand values to the right
    if (_counter == _duplicationCount - 1) {
      print("Resetting: Counter:" + _counter.toString());
      // Reset to 1 so as to offset the list and leave one unexplored set of hand values on the left
      _counter = 1;
      // Jump to the 2nd set of hand values
      return indexOfCurrentHand + values.length * _counter;
    }
    return newPosition;
  }
}

class SecondHandManager extends HandManager {
  SecondHandManager(ScrollController controller)
      : super(new List<int>.generate(60, (int index) => index), controller,
            DateFormat("ss")) {
    _duplicationCount = 4;
  }
}

class Hour24HandManager extends HandManager {
  Hour24HandManager(ScrollController controller)
      : super(new List<int>.generate(24, (int index) => index + 1), controller,
            DateFormat("HH")) {
    _duplicationCount = 4;
  }
}

class Hour12HandManager extends HandManager {
  Hour12HandManager(ScrollController controller)
      : super(new List<int>.generate(12, (int index) => index + 1), controller,
            DateFormat("hh")) {
    _duplicationCount = 4;
  }
}

class MinuteHandManager extends HandManager {
  MinuteHandManager(ScrollController controller)
      : super(new List<int>.generate(60, (int index) => index), controller,
            DateFormat("mm")) {
    _duplicationCount = 4;
  }
}

Widget buildHand(HandManager handManager, {fontSize: 50.0}) {
  return ListView.separated(
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
      },
      physics: NeverScrollableScrollPhysics(),
      controller: handManager.controller,
      itemCount: handManager.values.length * handManager.duplicationCount,
      scrollDirection: Axis.horizontal,
      itemBuilder: (BuildContext context, int index) {
        int currentTime = handManager.values[index % handManager.values.length];
        return Container(
          height: 50,
          width: 90,
          child: Center(
            child: Text(
              '${(currentTime <= 9) ? '0' + currentTime.toString() : currentTime}',
              style:
                  TextStyle(fontSize: fontSize, fontFamily: 'Segment7Standard'),
            ),
          ),
        );
      });
}
