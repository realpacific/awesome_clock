import 'package:awesome_clock/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

abstract class HandManager {
  /// All possible values for a hand
  ///
  /// for example 1,2,3,...12 are possible values of a 12-hour hand and 0,1,2,3..,59 for minutes and seconds hand.
  final List<int> values;

  final ScrollController controller;

  /// Should be at least 1 and less than [duplicationCount] to have a spare set of hand values on the left and right respectively.
  int _counter = 1;

  /// The number of times the [values] is duplicated while being displayed in a [Widget] for continuous forward flow.
  int _duplicationCount = 5;

  /// Used to extract the hand value from current time
  final DateFormat dateFormat;

  int _previousValue = 0;

  HandManager(this.values, this.controller, this.dateFormat);

  int get duplicationCount => _duplicationCount;

  /// Calculates the index of current hand value in the list of [values] while taking in account the [counter] and sparing one set of values at each side of the hand.
  ///
  /// Uses [dateFormat] to extract the current time from [dateTime].
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
    }
    // Reset the [_counter] since there is only one set of the hand values remaining, and we have to leave one set of hand values to the right
    if (_counter == _duplicationCount - 1) {
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
    _duplicationCount = HAND_VALUES_DUPLICATION;
  }
}

class Hour24HandManager extends HandManager {
  Hour24HandManager(ScrollController controller)
      : super(new List<int>.generate(24, (int index) => index + 1), controller,
      DateFormat("HH")) {
    _duplicationCount = HAND_VALUES_DUPLICATION;
  }
}

class Hour12HandManager extends HandManager {
  Hour12HandManager(ScrollController controller)
      : super(new List<int>.generate(12, (int index) => index + 1), controller,
      DateFormat("hh")) {
    _duplicationCount = HAND_VALUES_DUPLICATION;
  }
}

class MinuteHandManager extends HandManager {
  MinuteHandManager(ScrollController controller)
      : super(new List<int>.generate(60, (int index) => index), controller,
      DateFormat("mm")) {
    _duplicationCount = HAND_VALUES_DUPLICATION;
  }
}
