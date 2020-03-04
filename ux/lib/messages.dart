import 'dart:async';

import 'package:basketballdata/basketballdata.dart';
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
  String get addPlayerTooltip => Intl.message("Add Player",
      desc: "Message to on the tooltip to add a player", locale: locale);
  String get noTeams => Intl.message("No Teams",
      desc: "Message to say there are no teams currently setup",
      locale: locale);
  String get noGames => Intl.message("No Games",
      desc: "Message to say there are no games currently setup",
      locale: locale);
  String get noPlayers => Intl.message("No Players",
      desc: "Message to say there are no players currently setup",
      locale: locale);
  String get about => Intl.message("About",
      desc: "Menu item to open information about the app", locale: locale);
  String get eventTime =>
      Intl.message("Event Time", desc: "Time of the event", locale: locale);
  String get teamName =>
      Intl.message("Team Name", desc: "Name of the team", locale: locale);
  String get playerName =>
      Intl.message("Player Name", desc: "Name of the player", locale: locale);
  String get opponent => Intl.message("Opponent",
      desc: "The opponent in the game", locale: locale);
  String get location =>
      Intl.message("Location", desc: "Location of the game", locale: locale);
  String get jersyNumber => Intl.message("Jersey Number",
      desc: "Jersey number for the playerr", locale: locale);
  String get emptyText => Intl.message("Must not be empty",
      desc: "Hint text to say the name must not be empty", locale: locale);
  String get errorForm => Intl.message("Error in the form",
      desc: "Snackbar that pops up to show that there is an error",
      locale: locale);
  String get saveFailed => Intl.message("Save Failed",
      desc: "Failed to save a photo", locale: locale);
  String get saveButton =>
      Intl.message("SAVE", desc: "Text on a save button", locale: locale);
  String get statsButton =>
      Intl.message("STATS", desc: "Text on a stats button", locale: locale);
  String get subButton => Intl.message("SUB",
      desc: "Text on a substitution button", locale: locale);
  String get addPlayerButton => Intl.message("PLAYER",
      desc: "Text on a add player button", locale: locale);
  String get unknown => Intl.message("unknown",
      desc: "Used when the data is unknown", locale: locale);
  String get stats => Intl.message("Stats",
      desc: "Used when the data is unknown", locale: locale);
  String get players => Intl.message("Players",
      desc: "Used when the data is unknown", locale: locale);
  String get deletePlayer => Intl.message("Delete Player",
      desc: "Dialog title for deleting a playern", locale: locale);
  String get period => Intl.message("Period",
      desc: "Dialog title for sertting the current period", locale: locale);
  String get periodButton => Intl.message("PERIOD",
      desc: "Button to set the current period", locale: locale);
  String get noPlayersForTeamDialog => Intl.message(
      "You must have some players in a team "
      "to be able to create a game.",
      desc: "Text in a dialog to warn you need players",
      locale: locale);

  String deletePlayerAreYouSure(String name) {
    return Intl.message("Are you sure you want to delete the player $name?",
        desc: "Dialog text to ask if you aere sure about deleting the player",
        locale: locale);
  }

  String get shots => Intl.message("Shots",
      desc: "Heading for the shots sectionn", locale: locale);

  String getPeriodName(GamePeriod p) {
    switch (p) {
      case GamePeriod.NotStarted:
        return Intl.message("Not started",
            desc: "The game is not startedn", locale: locale);
      case GamePeriod.OverTime:
        return Intl.message("Overtime",
            desc: "The game is in overtime", locale: locale);
      case GamePeriod.Period1:
        return Intl.message("Period 1",
            desc: "The game is in period 1", locale: locale);
      case GamePeriod.Period2:
        return Intl.message("Period 2",
            desc: "The game is in period 2", locale: locale);
      case GamePeriod.Period3:
        return Intl.message("Period 3",
            desc: "The game is in period 3", locale: locale);
      case GamePeriod.Period4:
        return Intl.message("Period 4",
            desc: "The game is in period 4", locale: locale);
    }
    return unknown;
  }

  String getGameEventType(GameEvent p) {
    switch (p.type) {
      case GameEventType.Made:
        return Intl.message("+${p.points}",
            desc: "+num points", locale: locale);
        break;
      case GameEventType.Missed:
        return Intl.message("Missed ${p.points}",
            desc: "+num points", locale: locale);
        break;
      case GameEventType.Foul:
        return Intl.message("Foul", desc: "Foul on player", locale: locale);
        break;
      case GameEventType.Sub:
        return Intl.message("Subsitution",
            desc: "Subsitiution of player", locale: locale);
        break;
      case GameEventType.OffsensiveRebound:
        return Intl.message("Offsensive Rebound", locale: locale);
      case GameEventType.DefensiveRebound:
        return Intl.message("Defsensive Rebound", locale: locale);
      case GameEventType.Block:
        return Intl.message("Block", desc: "Block of a shot", locale: locale);
      case GameEventType.Assist:
        return Intl.message("Assist", desc: "Assist a shot", locale: locale);
      case GameEventType.Steal:
        return Intl.message("Steal", desc: "Steal a ball", locale: locale);
      case GameEventType.Turnover:
        return Intl.message("Turnover",
            desc: "Caused a turnover", locale: locale);
      case GameEventType.PeriodStart:
        return Intl.message("Start of ${getPeriodName(p.period)}",
            desc: "Start of period", locale: locale);
    }
    return unknown;
  }

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
