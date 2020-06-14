import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_web_profanity_check/consts.dart';
import 'package:flutter_web_profanity_check/feedback.dart' as fbs;
import 'package:flutter_web_profanity_check/query.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(ProfanityCheckApp());
}

class ProfanityCheckApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: kAppTitle,
      debugShowCheckedModeBanner: false,
      home: HomePage(
        title: kAppTitle,
        homeLogo: kHomeLogo,
        inputHint: kInputHint,
        submitLabel: kSubmitLabel,
        clearLabel: kClear,
        sourceCodeLocation: kSourceCodeLocation,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    @required String title,
    @required String homeLogo,
    @required String inputHint,
    @required String submitLabel,
    @required String clearLabel,
    @required String sourceCodeLocation,
  })  : assert(title is String),
        assert(homeLogo is String),
        assert(inputHint is String),
        assert(submitLabel is String),
        assert(clearLabel is String),
        assert(sourceCodeLocation is String),
        _title = title,
        _homeLogo = homeLogo,
        _inputHint = inputHint,
        _submitLabel = submitLabel,
        _clearLabel = clearLabel,
        _sourceCodeLocation = sourceCodeLocation;

  final String _title;
  final String _homeLogo;
  final String _inputHint;
  final String _submitLabel;
  final String _clearLabel;
  final String _sourceCodeLocation;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _editingController = TextEditingController();
  Iterable<fbs.Feedback> _feedbackList;
  bool _loading = false;

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 15.0,
        actions: <Widget>[
          FlatButton(
            child: Image.asset("assets/images/github.png"),
            onPressed: () async {
              _launchInBrowser(widget._sourceCodeLocation);
            },
          )
        ],
      ),
      body: SafeArea(
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
                _buildOutput(),
                _buildSubmitAndClear(),
              ],
            ),
          ),
        ),
      ),
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
        const Text(
          "v2.0",
        ),
      ],
    );
  }

  Widget _buildInput() {
    return Container(
      child: TextField(
        controller: _editingController,
        maxLength: 500,
        maxLines: 10,
        keyboardType: TextInputType.multiline,
        style: Theme.of(context).textTheme.bodyText1,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.all(16),
          hintText: widget._inputHint,
          hintStyle: Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(color: Colors.blueGrey),
          errorText:
              _isError ? (_feedbackList.first as fbs.QueryError).message : null,
          errorStyle: Theme.of(context).textTheme.caption.copyWith(
                color: Colors.red,
                fontSize: 15,
              ),
        ),
      ),
      margin: const EdgeInsets.only(
        left: 25,
        right: 25,
      ),
    );
  }

  Widget _buildOutput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Visibility(
          visible: _loading == false && _feedbackList != null,
          child: _buildScoreList(),
        ),
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
      ],
    );
  }

  Widget _buildScoreList() {
    if (_isError) {
      return const SizedBox.shrink();
    }
    // 0 - hate speech 1 - offensive language 2 - neither.
    return ListView(
      shrinkWrap: true,
      children: _feedbackList?.map((fbs.Feedback feedback) {
            final fbs.CheckFeedback cfb = feedback as fbs.CheckFeedback;
            return LinearProgressIndicator(
              value: (feedback as fbs.CheckFeedback).score,
              valueColor: AlwaysStoppedAnimation<Color>(cfb.score == 0
                  ? Colors.red
                  : cfb.score == 1 ? Colors.purple : Colors.green),
              minHeight: 15,
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
        RaisedButton(
          onPressed: _loading == true
              ? null
              : () async {
                  _setLoading(true);
                  final String input = _editingController.text?.trim() ?? "";
                  if (input.isNotEmpty) {
                    final Iterable<fbs.Feedback> feedbackList = await query(
                      endpoint: kEndpoint,
                      q: input,
                    );
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
        ),
        const SizedBox(
          width: 10,
        ),
        FlatButton(
          onPressed: _loading == true
              ? null
              : () {
                  _editingController.text = "";
                  _setFeedbackList(null);
                  _setLoading(false);
                },
          child: Text(
            widget._clearLabel,
            style: GoogleFonts.getFont('Roboto'),
          ),
        )
      ],
    );
  }
}
