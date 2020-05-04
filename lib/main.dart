import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_web_profanity_check/consts.dart';
import 'package:flutter_web_profanity_check/feedback.dart' as fbs;
import 'package:flutter_web_profanity_check/query.dart';
import 'package:google_fonts/google_fonts.dart';

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
  })  : assert(title is String),
        assert(homeLogo is String),
        assert(inputHint is String),
        assert(submitLabel is String),
        assert(clearLabel is String),
        _title = title,
        _homeLogo = homeLogo,
        _inputHint = inputHint,
        _submitLabel = submitLabel,
        _clearLabel = clearLabel;

  final String _title;
  final String _homeLogo;
  final String _inputHint;
  final String _submitLabel;
  final String _clearLabel;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _editingController = TextEditingController();
  fbs.Feedback _feedback;
  bool _loading = false;

  void _setFeedback(fbs.Feedback feedback) {
    setState(() {
      _feedback = feedback;
    });
  }

  void _setLoading(bool loading) {
    setState(() {
      _loading = loading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 15.0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  widget._homeLogo,
                  style: GoogleFonts.getFont('Anton')
                      .copyWith(height: 1.8, fontSize: 45),
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                  child: TextField(
                    controller: _editingController,
                    maxLength: 500,
                    maxLines: 10,
                    keyboardType: TextInputType.multiline,
                    style: Theme.of(context).textTheme.bodyText1,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.all(16),
                      errorText: _feedback is fbs.NegativeFeedback ||
                              _feedback is fbs.QueryError
                          ? _feedback?.message
                          : null,
                      errorStyle: Theme.of(context).textTheme.caption.copyWith(
                            color: Colors.red,
                          ),
                      hintText: widget._inputHint,
                      hintStyle: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .copyWith(color: Colors.blueGrey),
                    ),
                  ),
                  margin: const EdgeInsets.only(
                    left: 100,
                    right: 100,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Visibility(
                      visible: _loading == false &&
                          _feedback is fbs.PositiveFeedback,
                      child: Text(
                        _feedback?.message ?? "",
                        style: Theme.of(context).textTheme.caption.copyWith(
                              color: Colors.lightGreen,
                            ),
                      ),
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
                    const SizedBox(
                      height: 12,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () async {
                        _setLoading(true);
                        final String input =
                            _editingController.text?.trim() ?? "";
                        if (input.isNotEmpty) {
                          final fbs.Feedback feedback = await query(
                            endpoint: kEndpoint,
                            q: input,
                          );
                          _setFeedback(feedback);
                        } else {
                          _setFeedback(null);
                        }
                        _setLoading(false);
                      },
                      child: Text(
                        widget._submitLabel,
                        style: GoogleFonts.getFont('Roboto'),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        _editingController.text = "";
                        _setFeedback(null);
                        _setLoading(false);
                      },
                      child: Text(
                        widget._clearLabel,
                        style: GoogleFonts.getFont('Roboto'),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
