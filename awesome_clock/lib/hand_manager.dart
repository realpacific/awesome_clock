import 'package:awesome_clock/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Manages the possible values [handValues] a hand can display
/// and provides the index where the [controller] should scroll to
/// using [dateFormat] to find the index.
abstract class HandManager {
  /// All possible values for a hand.
  ///
  /// for example 1,2,3,...12 are possible values of a 12-hour hand
  /// and 0,1,2,3..,59 for minutes and seconds hand.
  List<int> _handValues;

  final ScrollController controller;

  /// Used to extract the hand value from current time.
  final DateFormat dateFormat;

  /// Should be at least 1 and less than [_duplicationCount]
  /// to have a spare set of hand values on the left and right respectively.
  int _counter = 1;

  /// The number of times the [_handValues] is duplicated
  /// while being displayed in widgets for continuous forward flow.
  int _duplicationCount = HAND_VALUES_DUPLICATION;

  int _previousValue = 0;

  HandManager(List<int> handValues, this.controller, this.dateFormat) {
    this._handValues = List<int>.unmodifiable(handValues);
  }

  List<int> get handValues => _handValues;

  int get duplicationCount => _duplicationCount;

  /// Calculates the index of current hand value in the list of [handValues]
  /// while taking in account the [_counter] and
  /// sparing one set of values at each side of the hand.
  ///
  /// Uses [dateFormat] to extract the current time from [dateTime]
  /// and returns the new index to scroll to.
  calculateIndex(DateTime dateTime) {
    final format = dateFormat.format(dateTime);
    final handTime = int.parse(format);
    final indexOfCurrentHand = handValues.indexOf(handTime);
    final newPosition = indexOfCurrentHand + handValues.length * _counter;
    if (_previousValue == handTime) {
      return newPosition;
    }
    _previousValue = handTime;
    // If the current hand value is equal to the max possible hand value
    // (that is the last element of [values]), then switch to new iteration.
    if (handTime == handValues.last) {
      _counter++;
    }
    // Reset the [_counter] since there is only one set of the hand values left,
    // and we have to leave one set of hand values to the right.
    if (_counter == _duplicationCount - 1) {
      // Reset to 1 so as to offset the list and leave one unexplored
      // set of hand values on the left.
      _counter = 1;
      // Jump to the 2nd set of hand values.
      return indexOfCurrentHand + handValues.length * _counter;
    }
    return newPosition;
  }
}

class SecondHandManager extends HandManager {
  SecondHandManager(ScrollController controller)
      : super(
    List<int>.generate(60, (int index) => index),
    controller,
    DateFormat("ss"),
  ) {
    _duplicationCount = 10;
  }
}

class Hour24HandManager extends HandManager {
  Hour24HandManager(ScrollController controller)
      : super(
    List<int>.generate(24, (int index) => index + 1),
    controller,
    DateFormat("HH"),
  );
}

class Hour12HandManager extends HandManager {
  Hour12HandManager(ScrollController controller)
      : super(
    List<int>.generate(12, (int index) => index + 1),
    controller,
    DateFormat("hh"),
  );
}

class MinuteHandManager extends HandManager {
  MinuteHandManager(ScrollController controller)
      : super(
    List<int>.generate(60, (int index) => index),
    controller,
    DateFormat("mm"),
  );
}
