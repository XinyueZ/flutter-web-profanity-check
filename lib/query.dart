import 'package:flutter_web_profanity_check/feedback.dart';
import 'package:http/http.dart' as web;

Future<Feedback> query({String endpoint, String q}) async {
  try {
    final String encodedQ = Uri.encodeQueryComponent(q);
    final String url = "$endpoint$encodedQ";
    final dynamic response = await web.get(url);
    final String responseText = response.body.toString();
    if (responseText == "true") {
      return NegativeFeedback();
    } else {
      return PositiveFeedback();
    }
  } catch (e) {
    return QueryError(msg: e.toString());
  }
}
