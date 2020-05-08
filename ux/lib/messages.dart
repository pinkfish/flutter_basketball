import 'dart:async';

import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/services/loginbloc.dart';
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

  String get addUserButton => Intl.message("Add User",
      desc: "Button to add a user to a team", locale: locale);

  String get usersTitle => Intl.message("Users",
      desc: "Title of the users section in the team details", locale: locale);

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

  String get noSeasons => Intl.message("No Seasons",
      desc: "Message to say there are no seasons currently setup",
      locale: locale);

  String get noPlayers => Intl.message("No Players",
      desc: "Message to say there are no players currently setup",
      locale: locale);

  String get about => Intl.message("About",
      desc: "Menu item to open information about the app", locale: locale);

  String get settings => Intl.message("Settings",
      desc: "Menu item to open information settings of the app",
      locale: locale);

  String get eventTime =>
      Intl.message("Event Time", desc: "Time of the event", locale: locale);

  String get teamName =>
      Intl.message("Team Name", desc: "Name of the team", locale: locale);

  String get seasonName =>
      Intl.message("Season Name", desc: "Name of the season", locale: locale);

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

  String get gamesButton =>
      Intl.message("GAMES", desc: "Text on a games button", locale: locale);

  String get editButton =>
      Intl.message("EDIT", desc: "Text on a edit button", locale: locale);

  String get endButton =>
      Intl.message("END", desc: "Text on a end button", locale: locale);

  String get foulButton =>
      Intl.message("FOUL", desc: "Text on the foul button", locale: locale);

  String get turnoverButton =>
      Intl.message("T/O", desc: "Turnover button", locale: locale);

  String get blockButton =>
      Intl.message("BLK", desc: "Block button", locale: locale);

  String get assistButton =>
      Intl.message("ASST", desc: "Assist button", locale: locale);

  String get stealButton =>
      Intl.message("STL", desc: "Steal button", locale: locale);

  String get defensiveReboundButton =>
      Intl.message("DEF RB", desc: "Defensive Rebound button", locale: locale);

  String get offensiveReboundButton =>
      Intl.message("OFF RB", desc: "Offensive Rebound button", locale: locale);

  String get subButton => Intl.message("SUB",
      desc: "Text on a substitution button", locale: locale);

  String get addPlayerButton => Intl.message("PLAYER",
      desc: "Text on a add player button", locale: locale);

  String get startButton => Intl.message("START",
      desc: "Text on a button to start the period", locale: locale);

  String get addGameButton =>
      Intl.message("GAME", desc: "Text on a add game button", locale: locale);

  String get addTeamButton =>
      Intl.message("TEAM", desc: "Text on a add team button", locale: locale);

  String get unknown => Intl.message("unknown",
      desc: "Used when the data is unknown", locale: locale);

  String get allPeriods => Intl.message("All Periods",
      desc: "Drop down menu item for all periods", locale: locale);

  String get timeline => Intl.message("Timeline",
      desc: "Bottom navigation to open the timeline", locale: locale);

  String get eventList => Intl.message("Events",
      desc: "Bottom navigation to open the events", locale: locale);

  String get stats => Intl.message("Stats",
      desc: "Used when the data is unknown", locale: locale);

  String get players => Intl.message("Players",
      desc: "Used when the data is unknown", locale: locale);

  String get video =>
      Intl.message("Video", desc: "Shows video for the game", locale: locale);

  String get noMedia =>
      Intl.message("No Media", desc: "No media to display", locale: locale);

  String get streamButton => Intl.message("STREAM",
      desc: "Button to display a stream", locale: locale);

  String get uploadButton => Intl.message("UPLOAD",
      desc: "Button to display upload a stream", locale: locale);

  String get deletePlayer => Intl.message("Delete Player",
      desc: "Dialog title for deleting a playern", locale: locale);

  String get endTimeout => Intl.message("End timeout",
      desc: "Text to end the timeout", locale: locale);

  String get period => Intl.message("Period",
      desc: "Dialog title for sertting the current period", locale: locale);

  String get periodButton => Intl.message("PERIOD",
      desc: "Button to set the current period", locale: locale);

  String get noPlayersForSeasonDialog => Intl.message(
      "You must have some players in a season "
      "to be able to create a game.",
      desc: "Text in a dialog to warn you need players",
      locale: locale);

  String get namerequired => Intl.message("Name is required.",
      desc: "Text in a snackbar to say the name is required", locale: locale);

  String get emailrequired => Intl.message("Email is required.",
      desc: "Text in a snackbar to say the email is required", locale: locale);

  String get invalidemail => Intl.message("Invalid email",
      desc: "Text in a snackbar to say the email is invalid", locale: locale);

  String get emptypassword => Intl.message("Empty password",
      desc: "Snackbar to show the password is empty", locale: locale);

  String get passwordtooshort =>
      Intl.message("Password must be 6 characters long",
          desc: "Snackbar message to say the password is too short",
          locale: locale);

  String get email =>
      Intl.message("Email", desc: "Email hint text", locale: locale);

  String get forgotPasswordButton =>
      Intl.message('FORGOT PASSWORD', name: 'Forgot password button text');

  String get forgotPasswordSent =>
      Intl.message('Sent email to your email address to reset your password',
          name: 'Forgot password happy button');

  String get forgotPasswordHint =>
      Intl.message('The email to resend the password to',
          name: 'Forgot password happy button');

  String get resendverifyButton => Intl.message('RESEND EMAIL',
      name: 'Button to resend the email to verify their email address');

  String get loginButton => Intl.message('LOGIN', name: 'Login button text');

  String get logoutButton => Intl.message('LOGOUT', name: 'Logout button text');

  String get createaccountButton =>
      Intl.message('CREATE', desc: 'Create account button text');

  String get phonenumberhint => Intl.message('Contact phone number',
      desc: 'Phone number for the edit box to edit the phone number');

  String get phonenumberhintoptional => Intl.message('Phone number (optional)',
      desc:
          'Phone number for the edit box to edit the phone number marked as optional');

  String get password =>
      Intl.message('Password', desc: 'Input box for a password');

  String get verifypassword => Intl.message('Verify password',
      desc: 'Input box for a verification to the main password password');

  String get formerror => Intl.message('Please fix the items outlined in red',
      name: 'Error in a form', desc: 'Error when submitting a form');

  String loginFailureReason(LoginFailedReason reason) {
    switch (reason) {
      case LoginFailedReason.BadPassword:
        return Intl.message('Email and/or password incorrect',
            desc: 'Passwords or email is not correct, login failed',
            locale: locale);
      case LoginFailedReason.InternalError:
        return Intl.message('Internal Error',
            desc:
                'Something happened inside the login system, not a bad password',
            locale: locale);
      case LoginFailedReason.Cancelled:
        return Intl.message('Login Cancelled',
            desc: 'Login was cancelled', locale: locale);
    }
    return unknown;
  }

  String get passwordsnotmatching => Intl.message('Passwords must match',
      desc: 'Passwords must match signup form error');

  String get createdaccount => Intl.message(
      "Created an account, please look in your email for the verification code..",
      desc:
          "Confirmation message after requesting the email verification code");

  String get youremailHint =>
      Intl.message('Your email address', name: 'Your email input field hint');

  String get displayname =>
      Intl.message('Name', desc: 'Name for the edit box to edit the user name');

  String get displaynamehint => Intl.message('Your name',
      desc: 'Name for the edit box to edit the user name');

  String get verifyemailsent => Intl.message(
      "Sent verification email, please check your email inbox.",
      desc:
          "Confirmation message after requesting the email verification code");
  String get verifyemailerror =>
      Intl.message("No account found for email or internal error occured");

  String verifyexplanation(String email) => Intl.message(
        'Email address $email needs to be verified, please check your email or resend the verification details.',
        name: 'Button to resend the email to verify their email address',
      );

  String get invalidUrl => Intl.message('Invalid URL',
      desc: 'Error in a form when the url is invalid');

  String get errorcreatinguser => Intl.message(
      "Error creating user, maybe the email address is already used");

  String get playVideoTitle =>
      Intl.message("View", desc: "Title for the tab to show the playing video");

  String get createnew => Intl.message(
        'Create new',
        name: 'Create new account button text',
      );

  String deletePlayerAreYouSure(String name) {
    return Intl.message("Are you sure you want to delete the player $name?",
        desc: "Dialog text to ask if you aere sure about deleting the player",
        locale: locale);
  }

  String get shots => Intl.message("Shots",
      desc: "Heading for the shots sectionn", locale: locale);

  String get allEvents => Intl.message("All Events",
      desc: "Drop down menu item for all events", locale: locale);

  String get fouls => Intl.message("Fouls",
      desc: "Drop down menu item for fouls", locale: locale);

  String get steals => Intl.message("Steals",
      desc: "Drop down menu item for steals", locale: locale);

  String get turnovers => Intl.message("Turnovers",
      desc: "Drop down menu item for turnovers", locale: locale);

  String get blocks => Intl.message("Blocks",
      desc: "Drop down menu item for fouls", locale: locale);

  String get rebounds => Intl.message("Rebounds",
      desc: "Drop down menu item for rebounds", locale: locale);

  String get points => Intl.message("Points",
      desc: "Drop down menu item for points", locale: locale);

  String get seasons => Intl.message("Seasons",
      desc: "Header for the seasons section", locale: locale);

  String get currentSeason => Intl.message("Current",
      desc: "Subtitle to markt he season as current", locale: locale);

  String get pointsTitle =>
      Intl.message("Pts", desc: "Points abbreviation", locale: locale);

  String get stealsTitle =>
      Intl.message("Stl", desc: "Steals abbreviation", locale: locale);

  String get blocksTitle =>
      Intl.message("Blk", desc: "Blocks abbreviation", locale: locale);

  String get turnoversTitle =>
      Intl.message("T/O", desc: "Turnover abbreviation", locale: locale);

  String get pointsGameSummary =>
      Intl.message("Pts", desc: "Points summary in game", locale: locale);

  String get percentageGameSummary => Intl.message("%age",
      desc: "Percentage made in game summary title", locale: locale);

  String get stealsGameSummary =>
      Intl.message("Steals", desc: "Steals summary in game", locale: locale);

  String get foulsGameSummary =>
      Intl.message("Fouls", desc: "Fouls summary in game", locale: locale);

  String get turnoversGameSummary =>
      Intl.message("T/O", desc: "Turnover summary in game", locale: locale);

  String get offensiveReboundTitle => Intl.message("O/RB",
      desc: "Offensive rebound abbreviation", locale: locale);

  String get defensiveReboundTitle => Intl.message("D/RB",
      desc: "Defensive rebound abbreviation", locale: locale);

  String get reboundsGameSummary =>
      Intl.message("RBs", desc: "Rebounds in game summary", locale: locale);

  String get videoTitle => Intl.message("Video",
      desc: "Button to open up the video section", locale: locale);

  String get urlTitle => Intl.message("URL",
      desc: "Title for the form field to set the url for media");

  String get descriptionTitle => Intl.message("Description",
      desc: "Title for the description of the media");

  String getUnverified(String name, bool unverified) {
    if (unverified) {
      return Intl.message("$name [unverified]",
          desc: "If the user is unverified", locale: locale);
    } else {
      return name;
    }
  }

  String seasonSummary(PlayerSeasonSummary summary) {
    return Intl.message(
        "Pts ${summary.summary.points} Blks ${summary.summary.blocks} Stls ${summary.summary.steals}",
        desc: "Subtitle to markt he season as current",
        locale: locale);
  }

  String playedSeasons(int num) {
    return Intl.message("Played $num seasons",
        desc: "Number of seasons playeed for the team", locale: locale);
  }

  String winLoss(int wins, int loses, int ties) {
    return Intl.message("Win $wins Loss $loses",
        desc: "Number of seasons playeed for the team", locale: locale);
  }

  String getGameVs(String opponent, String place) {
    return Intl.message("vs $opponent at $place",
        desc: "Heading for a game showing the opponent and the place",
        locale: locale);
  }

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
      case GamePeriod.Finished:
        return Intl.message("Finished",
            desc: "The game has finished", locale: locale);
    }
    return unknown;
  }

  String getGameEventType(GameEvent p) {
    switch (p.type) {
      case GameEventType.Made:
        return Intl.message("${p.points}", desc: "+num points", locale: locale);
        break;
      case GameEventType.Missed:
        return Intl.message("Miss ${p.points}",
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
        return Intl.message("Off Rebound", locale: locale);
      case GameEventType.DefensiveRebound:
        return Intl.message("Def Rebound", locale: locale);
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
      case GameEventType.PeriodEnd:
        return Intl.message("End of ${getPeriodName(p.period)}",
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
