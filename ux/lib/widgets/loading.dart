import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../messages.dart';

///
/// Shows a nifty loading message for bits of the app.
///
class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(Messages.of(context).loading,
          style: Theme.of(context).textTheme.display1),
      CircularProgressIndicator(),
    ]);
  }
}
