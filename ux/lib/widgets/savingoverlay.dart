import 'dart:math';

import 'package:flutter/material.dart';

import '../messages.dart';

///
/// Shows an overlay over the main class when it is saving with some useful
/// information, does it as a semi-transparent overlay.
///
class SavingOverlay extends StatelessWidget {
  SavingOverlay({@required bool saving, @required this.child, int quoteId})
      : _saving = saving ?? false,
        quoteId = quoteId ?? randomNum.nextInt(20000);

  final bool _saving;
  final Widget child;
  final int quoteId;

  static Random randomNum = Random.secure();

  @override
  Widget build(BuildContext context) {
    QuoteAndAuthor quote = Messages.of(context).quoteforsaving(quoteId);
    return new Stack(
      children: <Widget>[
        child,
        new AnimatedOpacity(
          opacity: _saving ? 0.8 : 0.0,
          duration: new Duration(seconds: 1),
          child: new Container(
            color: Colors.white,
            // Fill the whole page, drop it back when not saving to not
            // trap the gestures.
            constraints: _saving
                ? new BoxConstraints.expand()
                : new BoxConstraints.tight(const Size(0.0, 0.0)),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new RichText(
                  text: new TextSpan(
                    text: quote.quote,
                    style: Theme.of(context).textTheme.title,
                  ),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
                new SizedBox(height: 10.0),
                new Text(quote.author,
                    style: Theme.of(context)
                        .textTheme
                        .subhead
                        .copyWith(fontStyle: FontStyle.italic)),
                new SizedBox(height: 20.0),
                new CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
