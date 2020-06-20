import 'dart:convert';

import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:flutter_web_profanity_check/feedback.dart';

Future<Iterable<Feedback>> query({String endpoint, String q}) async {
  try {
    final String encodedQ = Uri.encodeQueryComponent(q);
    final String url = "$endpoint$encodedQ";
    final Response<dynamic> response = await Dio().get<dynamic>(url);
    return createFeedback(response);
  } catch (e) {
    return <Feedback>[QueryError(message: e.toString())];
  }
}

/* The response looks like below:
 * 0 - hate speech 1 - offensive language 2 - neither.
    {
    "0": 0.093,
    "1": 0.524,
    "2": 0.383,
    "q": "go to the hell"
    }
 */
Iterable<Feedback> createFeedback(dynamic response) {
  final Map<String, dynamic> feedsMap = DecoderHelper.getJsonDecoder()
      .convert(response.toString()) as Map<String, dynamic>;
  final List<Feedback> feedbackList = <Feedback>[];
  final double hateSpeechScore = feedsMap["0"] as double;
  feedbackList.add(CheckFeedback(
    type: CheckType.hateSpeech,
    score: hateSpeechScore,
  ));
  final double offensiveLanguageScore = feedsMap["1"] as double;
  feedbackList.add(CheckFeedback(
    type: CheckType.offensiveLanguage,
    score: offensiveLanguageScore,
  ));
  final double neitherScore = feedsMap["2"] as double;
  feedbackList.add(CheckFeedback(
    type: CheckType.neither,
    score: neitherScore,
  ));

  return feedbackList;
}

/* The response looks like below:
 * {"pos":23424234234}
 */
Future<Result<int>> addEntry({String endpoint, int cls, String tweet}) async {
  try {
    final String encodedTweet = Uri.encodeQueryComponent(tweet);
    final String url = "$endpoint?class=$cls&tweet=$encodedTweet";
    final Response<dynamic> response = await Dio().get<dynamic>(url);
    return ValueResult<int>(createPos(response));
  } catch (e, s) {
    return ErrorResult(e, s);
  }
}

int createPos(dynamic response) {
  final Map<String, dynamic> feedsMap = DecoderHelper.getJsonDecoder()
      .convert(response.toString()) as Map<String, dynamic>;
  return feedsMap["pos"] as int;
}

/* The response is not important.
 */
Future<Result<dynamic>> updateEntry({String endpoint, int pos, int cls}) async {
  try {
    final String url = "$endpoint?pos=$pos&class=$cls";
    await Dio().get<dynamic>(url);
    return ValueResult<dynamic>(null);
  } catch (e, s) {
    return ErrorResult(e, s);
  }
}

class DecoderHelper {
  static const Utf8Decoder utf8Decoder = Utf8Decoder();
  static const JsonDecoder jsonDecoder = JsonDecoder();

  static Utf8Decoder getUtf8Decoder() => utf8Decoder;

  static JsonDecoder getJsonDecoder() => jsonDecoder;
}
