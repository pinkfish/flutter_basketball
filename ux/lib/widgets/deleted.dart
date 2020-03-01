import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../messages.dart';

///
/// Shows a nifty deleted message for bits of the app.
///
class DeletedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(Messages.of(context).unknown,
          style: Theme.of(context).textTheme.display1),
      Icon(Icons.error, size: 40.0, color: Theme.of(context).errorColor),
    ]);
  }
}
