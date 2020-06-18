import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_web_profanity_check/consts.dart';

enum CheckType {
  hateSpeech,
  offensiveLanguage,
  neither,
}

abstract class Feedback {
  Feedback();
}

class CheckFeedback implements Feedback {
  const CheckFeedback({
    @required this.type,
    @required this.score,
  })  : assert(type is CheckType),
        assert(score is double);
  final CheckType type;
  final double score;

  String get label {
    switch (type) {
      case CheckType.hateSpeech:
        return kHateSpeechLabel;
      case CheckType.offensiveLanguage:
        return kOffensiveLanguageLabel;
      default:
        return kNeitherLabel;
    }
  }

  int get cls {
    switch (type) {
      case CheckType.hateSpeech:
        return 0;
      case CheckType.offensiveLanguage:
        return 1;
      default:
        return 2;
    }
  }

  Color get color {
    switch (type) {
      case CheckType.hateSpeech:
        return Colors.red;
      case CheckType.offensiveLanguage:
        return Colors.purple;
      default:
        return Colors.green;
    }
  }
}

class QueryError implements Feedback {
  QueryError({this.message = kQueryError}) : assert(message is String);
  String message;
}
