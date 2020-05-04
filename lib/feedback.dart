import 'package:flutter/foundation.dart';
import 'package:flutter_web_profanity_check/consts.dart';

abstract class Feedback {
  const Feedback({
    @required this.message,
  }) : assert(message is String);

  final String message;
}

class PositiveFeedback extends Feedback {
  PositiveFeedback({String msg = kPositiveInputFeedback}) : super(message: msg);
}

class NegativeFeedback extends Feedback {
  NegativeFeedback({String msg = kNegativeInputFeedback}) : super(message: msg);
}

class QueryError extends Feedback {
  QueryError({String msg = kQueryError}) : super(message: msg);
}
