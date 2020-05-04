import 'package:flutter_web_profanity_check/feedback.dart';
import 'package:http/http.dart' as web;

Future<Feedback> query({String endpoint, String q}) async {
  try {
    final String url = "$endpoint$q";
    final dynamic response = await web.read(url);
    final String responseText = response.toString();
    if (responseText == "true") {
      return NegativeFeedback();
    } else {
      return PositiveFeedback();
    }
  } catch (e) {
    return QueryError(msg: e.toString());
  }
}
