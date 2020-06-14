import 'package:flutter/foundation.dart';
import 'package:flutter_web_profanity_check/consts.dart';

enum CheckType { hateSpeech, offensiveLanguage, neither }

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
}

class QueryError implements Feedback {
  QueryError({this.message = kQueryError}) : assert(message is String);
  String message;
}
