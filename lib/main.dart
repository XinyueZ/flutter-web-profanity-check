import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_web_profanity_check/consts.dart';
import 'package:flutter_web_profanity_check/entry.dart';
import 'package:flutter_web_profanity_check/feedback.dart' as fbs;
import 'package:flutter_web_profanity_check/feedback.dart';
import 'package:flutter_web_profanity_check/net.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final String appVer = await _getAppVersion();

  runApp(ProfanityCheckApp(
    appVer: appVer,
  ));
}

Future<String> _getAppVersion() async {
  if (kIsWeb) {
    return "${WebVersionInfo.version}+${WebVersionInfo.buildNumber}";
  } else {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return "${packageInfo.version}+${packageInfo.buildNumber}";
  }
}

class ProfanityCheckApp extends StatelessWidget {
  const ProfanityCheckApp({
    @required String appVer,
  })  : assert(appVer is String),
        _appVer = appVer;
  final String _appVer;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppTitle,
      debugShowCheckedModeBanner: false,
      home: HomePage(
        appVer: _appVer,
        title: "",
        homeLogo: kHomeLogo,
        inputHint: kInputHint,
        submitLabel: kSubmitLabel,
        clearLabel: kClear,
        tooltip: kTooltip,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    @required String appVer,
    @required String title,
    @required String homeLogo,
    @required String inputHint,
    @required String submitLabel,
    @required String clearLabel,
    @required String tooltip,
  })  : assert(appVer is String),
        assert(title is String),
        assert(homeLogo is String),
        assert(inputHint is String),
        assert(submitLabel is String),
        assert(clearLabel is String),
        assert(tooltip is String),
        _appVer = appVer,
        _title = title,
        _homeLogo = homeLogo,
        _inputHint = inputHint,
        _submitLabel = submitLabel,
        _clearLabel = clearLabel,
        _tooltip = tooltip;

  final String _appVer;
  final String _title;
  final String _homeLogo;
  final String _inputHint;
  final String _submitLabel;
  final String _clearLabel;
  final String _tooltip;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Duration _kAnimationDuration = Duration(milliseconds: 300);

  final TextEditingController _editingController = TextEditingController();
  Iterable<fbs.Feedback> _feedbackList;
  bool _loading = false;
  bool _showSuggestions = false;
  CheckFeedback _suggestion;
  AddEntry _addEntry;
  UpdateEntry _updateEntry;
  int _pos;

  bool get _isError =>
      _feedbackList?.length == 1 && _feedbackList.first is fbs.QueryError;

  void _setFeedbackList(Iterable<fbs.Feedback> feedbackList) {
    setState(() {
      _feedbackList = feedbackList;
    });
  }

  void _setLoading(bool loading) {
    setState(() {
      _loading = loading;
    });
  }

  void _toggleSuggestions() {
    setState(() {
      _showSuggestions = !_showSuggestions;
    });
  }

  void _setSuggestions(bool showSuggestions) {
    setState(() {
      _showSuggestions = showSuggestions;
    });
  }

  void _setSuggestion(CheckFeedback suggestion) {
    setState(() {
      _suggestion = suggestion;
    });
  }

  void _setAddEntry(AddEntry addEntry) {
    setState(() {
      _addEntry = addEntry;
    });
  }

  void _setUpdateEntry(UpdateEntry updateEntry) {
    setState(() {
      _updateEntry = updateEntry;
    });
  }

  void _setPos(int pos) {
    setState(() {
      _pos = pos;
    });
  }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 50),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildLogo(),
                  const SizedBox(
                    height: 30,
                  ),
                  _buildInput(),
                  Stack(
                    alignment: AlignmentDirectional.center,
                    children: <Widget>[
                      _buildSubmitAndClear(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          _buildTypeSuggestions(),
                          _buildSuggestionWarning(),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  _buildOutput(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(widget._title),
      backgroundColor: Colors.white,
      elevation: 15.0,
      actions: <Widget>[
        FlatButton(
          child: Text(
            "API",
            textAlign: TextAlign.center,
            style: GoogleFonts.getFont('Source Code Pro').copyWith(
              fontSize: 20,
              color: Colors.teal,
            ),
          ),
          onPressed: () async {
            _launchInBrowser("${kEndpointCheck}hello");
          },
        ),
        FlatButton(
          child: Text(
            "Model",
            textAlign: TextAlign.center,
            style: GoogleFonts.getFont('Source Code Pro').copyWith(
              fontSize: 20,
              color: Colors.teal,
            ),
          ),
          onPressed: () async {
            _launchInBrowser(kModelDownload);
          },
        ),
        FlatButton(
          child: Text(
            "Data",
            textAlign: TextAlign.center,
            style: GoogleFonts.getFont('Source Code Pro').copyWith(
              fontSize: 20,
              color: Colors.teal,
            ),
          ),
          onPressed: () async {
            _launchInBrowser(kLabeledData);
          },
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          widget._homeLogo,
          style:
              GoogleFonts.getFont('Anton').copyWith(height: 1.8, fontSize: 45),
        ),
        Text(
          widget._appVer,
        ),
      ],
    );
  }

  Widget _buildInput() {
    return TextField(
      controller: _editingController,
      maxLength: 500,
      maxLines: 5,
      keyboardType: TextInputType.multiline,
      style: Theme.of(context).textTheme.bodyText1,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.all(16),
        hintText: widget._inputHint,
        hintStyle: Theme.of(context).textTheme.bodyText1.copyWith(
              color: Colors.blueGrey,
            ),
        errorText:
            _isError ? (_feedbackList.first as fbs.QueryError).message : null,
        errorStyle: Theme.of(context).textTheme.caption.copyWith(
              color: Colors.red,
              fontSize: 15,
            ),
      ),
    );
  }

  Widget _buildOutput() {
    return AnimatedOpacity(
      opacity: _loading ? 0 : 1,
      duration: _kAnimationDuration,
      child: AnimatedContainer(
        duration: _kAnimationDuration,
        curve: Curves.easeOutSine,
        height: _isError || _feedbackList == null ? 0 : null,
        child: _buildScoreBars(),
      ),
    );
  }

  Widget _buildScoreBars() {
    if (_isError || _feedbackList == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: _feedbackList.map((fbs.Feedback feedback) {
            final fbs.CheckFeedback cfb = feedback as fbs.CheckFeedback;
            return Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                LinearProgressIndicator(
                  value: (feedback as fbs.CheckFeedback).score,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    cfb.type == fbs.CheckType.hateSpeech
                        ? Colors.red
                        : cfb.type == fbs.CheckType.offensiveLanguage
                            ? Colors.purple
                            : Colors.green,
                  ),
                  minHeight: 20,
                ),
                Text(
                  cfb.label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.getFont('Source Code Pro').copyWith(
                    fontSize: 13,
                    color: Colors.teal,
                  ),
                ),
              ],
            );
          })?.toList() ??
          <Widget>[],
    );
  }

  Widget _buildSubmitAndClear() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Visibility(
          visible: _loading == true,
          child: const SizedBox(
            width: 15,
            height: 15,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        _buildSubmit(),
        const SizedBox(
          width: 10,
        ),
        _buildClear(),
      ],
    );
  }

  Widget _buildClear() {
    return FlatButton(
      onPressed: _loading == true ? null : () => _clear(true),
      child: Text(
        widget._clearLabel,
        style: GoogleFonts.getFont('Roboto'),
      ),
    );
  }

  void _clear(bool alsoInput) {
    if (alsoInput) {
      _editingController.text = "";
    }
    _setFeedbackList(null);
    _setLoading(false);
    _setSuggestions(false);
    _setSuggestion(null);
    _setAddEntry(null);
    _setUpdateEntry(null);
    _setPos(null);
  }

  Widget _buildSubmit() {
    return RaisedButton(
      onPressed: _loading == true
          ? null
          : () async {
              _clear(false);

              _setLoading(true);
              final String input = _editingController.text?.trim() ?? "";
              if (input.isNotEmpty) {
                final Iterable<fbs.Feedback> feedbackList = await query(
                  endpoint: kEndpointCheck,
                  q: input,
                );

                final fbs.Feedback maxFeedback = maxBy(
                    feedbackList,
                    (fbs.Feedback feedback) =>
                        (feedback as fbs.CheckFeedback).score);

                final int cls = fbs.CheckType.hateSpeech ==
                        (maxFeedback as fbs.CheckFeedback).type
                    ? 0
                    : fbs.CheckType.offensiveLanguage ==
                            (maxFeedback as fbs.CheckFeedback).type
                        ? 1
                        : 2;

                final Result<int> posResult = await addEntry(
                  endpoint: kEndpointAddEntry,
                  cls: cls,
                  tweet: input,
                );

                if (posResult.isValue) {
                  _setPos(posResult.asValue.value);
                }

                _setFeedbackList(feedbackList);
              } else {
                _setFeedbackList(null);
              }

              _setLoading(false);
            },
      child: Text(
        widget._submitLabel,
        style: GoogleFonts.getFont('Roboto'),
      ),
    );
  }

  bool get _isCompleted =>
      !(_loading || _isError || _feedbackList == null) && _pos != null;

  Widget _buildSuggestionWarning() {
    return AnimatedOpacity(
      opacity: _isCompleted ? 1 : 0,
      duration: _kAnimationDuration,
      child: AnimatedContainer(
        duration: _kAnimationDuration,
        curve: Curves.easeOutSine,
        width: _isCompleted ? null : 0,
        height: _isCompleted ? null : 0,
        child: _buildTooltip(
          IconButton(
            icon: Image.asset(
              "assets/images/ic_warning.png",
              width: 15,
              height: 15,
            ),
            onPressed: _isCompleted
                ? () {
                    _toggleSuggestions();
                  }
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildTooltip(Widget child) {
    return Tooltip(
      message: widget._tooltip,
      child: child,
    );
  }

  Widget _buildTypeSuggestions() {
    return AnimatedOpacity(
      duration: _kAnimationDuration,
      curve: Curves.easeOutSine,
      opacity: _showSuggestions ? 1 : 0,
      child: AnimatedContainer(
        duration: _kAnimationDuration,
        curve: Curves.easeOutSine,
        width: _showSuggestions ? null : 0,
        height: _showSuggestions ? null : 0,
        margin: EdgeInsets.symmetric(horizontal: _showSuggestions ? 32 : 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _buildTypeSuggestion(
              const CheckFeedback(type: CheckType.hateSpeech, score: 0),
              CheckType.hateSpeech == _suggestion?.type,
            ),
            const SizedBox(
              width: 5,
            ),
            _buildTypeSuggestion(
              const CheckFeedback(type: CheckType.offensiveLanguage, score: 0),
              CheckType.offensiveLanguage == _suggestion?.type,
            ),
            const SizedBox(
              width: 5,
            ),
            _buildTypeSuggestion(
              const CheckFeedback(type: CheckType.neither, score: 0),
              CheckType.neither == _suggestion?.type,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSuggestion(fbs.CheckFeedback checkFeedback, bool checked) {
    return ActionChip(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      label: Text(
        checkFeedback.label,
        style: Theme.of(context).textTheme.caption.copyWith(
              color: checked ? Colors.indigo : Colors.white,
            ),
      ),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
          side: BorderSide(
            color: Colors.indigo,
            width: 1,
          )),
      shadowColor: Colors.transparent,
      backgroundColor: checked ? Colors.white : Colors.indigo,
      onPressed: () {
        _setSuggestion(checkFeedback);
      },
    );
  }
}
