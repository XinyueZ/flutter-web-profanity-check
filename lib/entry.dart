import 'package:flutter/foundation.dart';

class AddEntry {
  AddEntry({
    @required this.cls,
    @required this.tweet,
  }) : assert(cls != null && tweet != null);
  int cls;
  String tweet;
}

class UpdateEntry {
  UpdateEntry({
    @required this.pos,
    @required this.cls,
  }) : assert(cls != null && pos != null);
  int pos;
  int cls;
}
