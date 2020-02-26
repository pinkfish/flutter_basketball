import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'l10n/messages_all.dart';

class Messages {
  static Future<Messages> load(Locale locale) async {
    final String name =
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return new Messages(localeName);
    });
  }

  static Messages of(BuildContext context) {
    return Localizations.of<Messages>(context, Messages);
  }

  Messages(this.locale);

  final String locale;

  String get title => Intl.message("Basketball stats",
      desc: "Title of the app", locale: locale);
  String get loading => Intl.message("Loading...",
      desc: "Message to show while loading data", locale: locale);
  String get addTeamTooltip => Intl.message("Add Team",
      desc: "Message to on the tooltip to add a team", locale: locale);
  String get addGameTooltip => Intl.message("Add Game",
      desc: "Message to on the tooltip to add a game", locale: locale);
  String get noTeams => Intl.message("No Teams",
      desc: "Message to say there are no teams currently setup",
      locale: locale);
  String get about => Intl.message("About",
      desc: "Menu item to open information about the app", locale: locale);
  String get teamName =>
      Intl.message("Team Name", desc: "Name of the team", locale: locale);
  String get emptyText => Intl.message("Must not be empty",
      desc: "Hint text to say the name must not be empty", locale: locale);
  String get errorForm => Intl.message("Error in the form",
      desc: "Snackbar that pops up to show that there is an error",
      locale: locale);
  String get saveFailed => Intl.message("Save Failed",
      desc: "Failed to save a photo", locale: locale);
  String get saveButton =>
      Intl.message("SAVE", desc: "Text on a save button", locale: locale);
  QuoteAndAuthor quoteforsaving(int quoteId) {
    switch (quoteId % 4) {
      case 0:
        return new QuoteAndAuthor(
            quote:
                Intl.message("Lies, Damn Lies and Statistics", locale: locale),
            author: Intl.message("Mark Twain", locale: locale));
      case 1:
        return new QuoteAndAuthor(
            quote: Intl.message(
                "I've missed more than 9000 shots in my career. "
                "I've lost almost 300 games. 26 times, "
                "I've been trusted to take the game winning shot and missed. "
                "I've failed over and over and over again in my life. "
                "And that is why I succeed.",
                locale: locale),
            author: Intl.message("Michael Jordan", locale: locale));
      case 2:
        return new QuoteAndAuthor(
          quote: Intl.message(
              "I know I am getting better at golf because I am hitting fewer spectators.",
              locale: locale),
          author: Intl.message("Gerald R. Ford", locale: locale),
        );
      default:
        return new QuoteAndAuthor(
            quote: Intl.message("Don't Panic", locale: locale),
            author: Intl.message("Douglas Adams", locale: locale));
    }
  }
}

class QuoteAndAuthor {
  QuoteAndAuthor({this.quote, this.author});

  String quote;
  String author;
}

class MessagesDelegate extends LocalizationsDelegate<Messages> {
  const MessagesDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<Messages> load(Locale locale) => Messages.load(locale);

  @override
  bool shouldReload(MessagesDelegate old) => false;
}
