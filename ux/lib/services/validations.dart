import 'package:flutter/material.dart';

import '../messages.dart';

class Validations {
  String validateName(BuildContext context, String value) {
    if (value.isEmpty) {
      return Messages.of(context).namerequired;
    }

    return null;
  }

  String validateDisplayName(BuildContext context, String value) {
    if (value.isEmpty) {
      return Messages.of(context).namerequired;
    }
    return null;
  }

  String validateEmail(BuildContext context, String value) {
    if (value.isEmpty) {
      return Messages.of(context).emailrequired;
    }
    final RegExp nameExp = new RegExp(r'^\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,3}$');
    if (!nameExp.hasMatch(value)) {
      return Messages.of(context).invalidemail;
    }
    return null;
  }

  String validatePassword(BuildContext context, String value) {
    if (value.isEmpty) {
      return Messages.of(context).emptypassword;
    }
    return null;
  }
}
