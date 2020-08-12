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

  String get titleOfApp => Intl.message("Basketball stats",
      desc: "Title of the app", locale: locale);
  String get loadingText => Intl.message("Loading...",
      desc: "Message to show while loading data", locale: locale);
  String get addTeamTooltip => Intl.message("Add Team",
      desc: "Message to on the tooltip to add a team", locale: locale);
  String get signinWithGoolge => Intl.message('Sign in with Google',
      desc: "Sign in button for logging into google", locale: locale);

  String get addUserButton => Intl.message("Add User",
      desc: "Button to add a user to a team", locale: locale);

  String get addGuestPlayerButton => Intl.message("GUEST",
      desc: "Button text for adding a guest player", locale: locale);

  String get guestPlayersForGame => Intl.message("Guest players",
      desc: "Title to show the guest players in the game", locale: locale);

  String get gameDetails => Intl.message("Details",
      desc: "Description of the form flow that has the game details",
      locale: locale);

  String get noGuestPlayers => Intl.message("No guest players",
      desc: "No guest players for the game", locale: locale);

  String get allSeasons => Intl.message("All Seasons",
      desc: "Tag on the dropdown to show all the seasons", locale: locale);

  String get allPlayers => Intl.message("All Players",
      desc: "Tag on the dropdown to show all the players", locale: locale);

  String get addGameSummary => Intl.message("Summary",
      desc: "Title for the page showing the add game summary", locale: locale);

  String get addSeasonTooltip => Intl.message("Add Season", locale: locale);

  String get addSeasonButton => Intl.message("SEASON", locale: locale);

  String get editTeamTooltip => Intl.message("Edit Team", locale: locale);

  String get editPlayerTitle => Intl.message("Edit Player", locale: locale);

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

  String get uxSettingsSection => Intl.message("UI",
      desc: "Settings header for the UI settings", locale: locale);

  String get inviteToTeam => Intl.message("Invite to Team",
      desc: "Button to show the invite to team", locale: locale);

  String get lightMode =>
      Intl.message("Light mode", desc: "Light mode for the ux", locale: locale);

  String get noPlayersWithStats => Intl.message("No Players with state",
      desc: "Message to say there are no players currently setup",
      locale: locale);

  String get about => Intl.message("About",
      desc: "Menu item to open information about the app", locale: locale);

  String get finishStreamingVideo =>
      Intl.message("Do you want to finish streaming the game?",
          desc: "Menu item to open information about the app", locale: locale);

  String get failedToTakeThumbnail =>
      Intl.message("Failed to create thumbnail for the stream", locale: locale);

  String get videoStreaming => Intl.message("Video Steaming",
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

  String get selectMediaType => Intl.message("Select Media",
      desc: "Title for the dialog to select a video", locale: locale);

  String get selectPlayer => Intl.message("Select Player",
      desc: "Selects the player for the event", locale: locale);

  String get videoMediaType =>
      Intl.message("Upload Video", desc: "Upload a video", locale: locale);

  String get imageMediaType =>
      Intl.message("Photo", desc: "Upload a photo", locale: locale);

  String get streamMediaType =>
      Intl.message("Stream Live", desc: "Live video streaming", locale: locale);
  String get takePhotoButton =>
      Intl.message("CAMERA", desc: "Live video streaming", locale: locale);

  String get selectImageButton =>
      Intl.message("GALLERY", desc: "Live video streaming", locale: locale);

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

  String get forgotPasswordButton => Intl.message('FORGOT PASSWORD',
      desc: 'Forgot password button text', locale: locale);

  String get forgotPasswordSent =>
      Intl.message('Sent email to your email address to reset your password',
          desc: 'Forgot password happy button', locale: locale);

  String get usersDescriptions => Intl.message(
      'The users who have access to this team, they can see the '
      'stats and edit the team/seasons/players.',
      locale: locale);

  String get forgotPasswordHint =>
      Intl.message('The email to resend the password to',
          desc: 'Forgot password happy button', locale: locale);

  String get resendverifyButton => Intl.message('RESEND EMAIL',
      desc: 'Button to resend the email to verify their email address',
      locale: locale);

  String get loginButton =>
      Intl.message('LOGIN', desc: 'Login button text', locale: locale);

  String get logoutButton =>
      Intl.message('LOGOUT', desc: 'Logout button text', locale: locale);

  String get skipButton =>
      Intl.message('SKIP', desc: 'Skip button text', locale: locale);

  String get createaccountButton => Intl.message('CREATE',
      desc: 'Create account button text', locale: locale);

  String get doneButton =>
      Intl.message('DONE', desc: 'Done completely button', locale: locale);

  String get phonenumberhint => Intl.message('Contact phone number',
      desc: 'Phone number for the edit box to edit the phone number');

  String get phonenumberhintoptional => Intl.message('Phone number (optional)',
      desc:
          'Phone number for the edit box to edit the phone number marked as optional',
      locale: locale);

  String get password => Intl.message('Password',
      desc: 'Input box for a password', locale: locale);

  String get verifypassword => Intl.message('Verify password',
      desc: 'Input box for a verification to the main password password',
      locale: locale);

  String get formerror => Intl.message('Please fix the items outlined in red',
      desc: 'Error when submitting a form', locale: locale);
  String get optional => Intl.message('Optional',
      desc: 'Optional subtitle for a stepper', locale: locale);

  String loginFailureReason(LoginFailedReason reason) {
    switch (reason) {
      case LoginFailedReason.BadPassword:
        return loginFailureBadPassword;
      case LoginFailedReason.InternalError:
        return loginFailureInternalError;
      case LoginFailedReason.Cancelled:
        return loginFailureCancelled;
    }
    return unknown;
  }

  String foultype(GameFoulType type) {
    switch (type) {
      case GameFoulType.Personal:
        return personalFoulType;
      case GameFoulType.Flagrant:
        return flagrantFoulType;
      case GameFoulType.Technical:
        return technicalFoulType;
    }
    return unknown;
  }

  String get personalFoulType =>
      Intl.message('Personal Foul', desc: 'Personal foul type', locale: locale);
  String get technicalFoulType => Intl.message('Technical Foul',
      desc: 'Technical foul type', locale: locale);
  String get flagrantFoulType =>
      Intl.message('Flagrant Foul', desc: 'Flagrant foul type', locale: locale);

  String get loginFailureBadPassword =>
      Intl.message('Email and/or password incorrect',
          desc: 'Passwords or email is not correct, login failed',
          locale: locale);

  String get loginFailureInternalError => Intl.message('Internal Error',
      desc: 'Something happened inside the login system, not a bad password',
      locale: locale);

  String get loginFailureCancelled => Intl.message('Login Cancelled',
      desc: 'Login was cancelled', locale: locale);

  String get passwordsnotmatching => Intl.message('Passwords must match',
      desc: 'Passwords must match signup form error', locale: locale);

  String get createdaccount => Intl.message(
      "Created an account, please look in your email for the verification code..",
      desc: "Confirmation message after requesting the email verification code",
      locale: locale);

  String get youremailHint => Intl.message('Your email address',
      desc: 'Your email input field hint', locale: locale);

  String get displayname => Intl.message('Name',
      desc: 'Name for the edit box to edit the user name', locale: locale);

  String get displaynamehint => Intl.message('Your name',
      desc: 'Name for the edit box to edit the user name', locale: locale);

  String get verifyemailsent => Intl.message(
      "Sent verification email, please check your email inbox.",
      desc: "Confirmation message after requesting the email verification code",
      locale: locale);
  String get verifyemailerror =>
      Intl.message("No account found for email or internal error occured",
          locale: locale);

  String verifyexplanation(String email) => Intl.message(
      'Email address $email needs to be verified, please check your email or resend the verification details.',
      desc: 'Button to resend the email to verify their email address',
      args: [email],
      name: "verifyexplanation");

  String get invalidUrl => Intl.message('Invalid URL',
      desc: 'Error in a form when the url is invalid', locale: locale);

  String get errorcreatinguser => Intl.message(
      "Error creating user, maybe the email address is already used",
      locale: locale);

  String get playVideoTitle => Intl.message("View",
      desc: "Title for the tab to show the playing video", locale: locale);

  String get createnew => Intl.message('Create new',
      desc: 'Create new account button text', locale: locale);

  String deletePlayerAreYouSure(String name) {
    return Intl.message("Are you sure you want to delete the player $name?",
        desc: "Dialog text to ask if you aere sure about deleting the player",
        args: [name],
        locale: locale,
        name: "deletePlayerAreYouSure");
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
      desc: "Title for the form field to set the url for media",
      locale: locale);

  String get descriptionTitle => Intl.message("Description",
      desc: "Title for the description of the media", locale: locale);

  String get deleteInvite => Intl.message('Delete invite',
      desc: 'Title for the dialog to delete an invite', locale: locale);

  String get invite => Intl.message('Invites',
      desc: 'Title for the screen with the list of current invites',
      locale: locale);

  String get noinvites => Intl.message('No invites', locale: locale);

  String get saveButtonText => Intl.message('SAVE', locale: locale);

  String get aboutstatsappdescription => Intl.message(
      'Basketball stats is an exciting app to show stats'
      'about basketball games.  It shows nifty graphs and fun stuff',
      locale: locale);

  String getUnverified(String name, bool unverified) {
    if (unverified) {
      return Intl.message("$name [unverified]",
          args: [name, unverified],
          desc: "If the user is unverified",
          locale: locale,
          name: "getUnverified");
    } else {
      return name;
    }
  }

  String seasonSummary(PlayerSeasonSummary summary) {
    return seasonSummaryExpanded(
        summary.summary.points, summary.summary.blocks, summary.summary.steals);
  }

  String seasonSummaryExpanded(int points, int blocks, int steals) {
    return Intl.message("Pts $points Blks $blocks Stls $steals",
        desc: "Subtitle to markt he season as current",
        args: [points, blocks, steals],
        locale: locale,
        name: "seasonSummaryExpanded");
  }

  String playedSeasons(int numSeasons) {
    return Intl.message("Played $numSeasons seasons",
        args: [numSeasons],
        desc: "Number of seasons playeed for the team",
        locale: locale,
        name: "playedSeasons");
  }

  String winLoss(int wins, int loses, int ties) {
    return Intl.message("Win $wins Loss $loses",
        args: [wins, loses, ties],
        desc: "Number of seasons playeed for the team",
        locale: locale,
        name: "winLoss");
  }

  String getGameVs(String opponent, String place) {
    return Intl.message("vs $opponent at $place",
        args: [opponent, place],
        desc: "Heading for a game showing the opponent and the place",
        locale: locale,
        name: "getGameVs");
  }

  String invitedpeople(int numPeopleInvited) {
    return Intl.message("Invited: $numPeopleInvited",
        args: [numPeopleInvited],
        desc: "Heading showing the number of pending invites",
        locale: locale,
        name: "invitedpeople");
  }

  String getPeriodName(GamePeriod p) {
    switch (p) {
      case GamePeriod.NotStarted:
        return periodNameNotStarted;
      case GamePeriod.OverTime:
        return periodNameOverTime;
      case GamePeriod.Period1:
        return periodNamePeriod1;
      case GamePeriod.Period2:
        return periodNamePeriod2;
      case GamePeriod.Period3:
        return periodNamePeriod3;
      case GamePeriod.Period4:
        return periodNamePeriod4;
      case GamePeriod.Finished:
        return periodNameFinished;
    }
    return unknown;
  }

  String get periodNameNotStarted => Intl.message("Not started",
      desc: "The game is not started", locale: locale);

  String get periodNameOverTime =>
      Intl.message("Overtime", desc: "The game is in overtime", locale: locale);

  String get periodNamePeriod1 =>
      Intl.message("Period 1", desc: "The game is in period 1", locale: locale);
  String get periodNamePeriod2 =>
      Intl.message("Period 2", desc: "The game is in period 2", locale: locale);

  String get periodNamePeriod3 =>
      Intl.message("Period 3", desc: "The game is in period 3", locale: locale);

  String get periodNamePeriod4 =>
      Intl.message("Period 4", desc: "The game is in period 4", locale: locale);

  String get periodNameFinished =>
      Intl.message("Finished", desc: "The game has finished", locale: locale);

  String getGameEventType(GameEvent p) {
    switch (p.type) {
      case GameEventType.Made:
        return madeEventType(p.points);
      case GameEventType.Missed:
        return missedEventType(p.points);
      case GameEventType.Foul:
        return foulEventType;
      case GameEventType.Sub:
        return subsitutionEventType;
      case GameEventType.OffsensiveRebound:
        return offensiveReboundEventType;
      case GameEventType.DefensiveRebound:
        return defensiveReboundEventType;
      case GameEventType.Block:
        return blockEventType;
      case GameEventType.Steal:
        return stealEventType;
      case GameEventType.Turnover:
        return turnOverEventType;
      case GameEventType.PeriodStart:
        return periodStart(getPeriodName(p.period));
      case GameEventType.PeriodEnd:
        return periodEnd(getPeriodName(p.period));
    }
    return unknown;
  }

  String madeEventType(int points) {
    return Intl.message("$points",
        args: [points],
        desc: "+num points",
        locale: locale,
        name: "madeEventType");
  }

  String missedEventType(int points) {
    return Intl.message("Miss $points",
        args: [points],
        desc: "missed num points",
        locale: locale,
        name: "missedEventType");
  }

  String get foulEventType =>
      Intl.message("Foul", desc: "Foul on player", locale: locale);

  String get subsitutionEventType => Intl.message("Subsitution",
      desc: "Subsitiution of player", locale: locale);

  String get offensiveReboundEventType =>
      Intl.message("Off Rebound", locale: locale);

  String get defensiveReboundEventType =>
      Intl.message("Def Rebound", locale: locale);

  String get blockEventType =>
      Intl.message("Block", desc: "Block of a shot", locale: locale);

  String get stealEventType => Intl.message("Steal",
      desc: "Steal a ball", locale: locale, name: "stealEventType");

  String get turnOverEventType => Intl.message("Turnover",
      desc: "Caused a turnover", locale: locale, name: "turnOverEventType");

  String get assistTitle => Intl.message("Assisted",
      desc: "Title for the section on a player assist", locale: locale);

  String periodStart(String periodName) {
    return Intl.message("Start of $periodName",
        args: [periodName],
        desc: "Start of period",
        locale: locale,
        name: "periodStart");
  }

  String periodEnd(String periodName) {
    return Intl.message("End of $periodName",
        args: [periodName],
        desc: "End of period",
        locale: locale,
        name: "periodEnd");
  }

  QuoteAndAuthor quoteforsaving(int quoteId) {
    switch (quoteId % 4) {
      case 0:
        return new QuoteAndAuthor(quote: liesDamnLies, author: markTwain);
      case 1:
        return new QuoteAndAuthor(quote: missedShots, author: michaelJordan);
      case 2:
        return new QuoteAndAuthor(
          quote: missingSpectators,
          author: geraldFord,
        );
      default:
        return new QuoteAndAuthor(quote: dontPanic, author: douglaseAdams);
    }
  }

  String get liesDamnLies =>
      Intl.message("Lies, Damn Lies and Statistics", locale: locale);
  String get markTwain => Intl.message("Mark Twain", locale: locale);

  String get missedShots => Intl.message(
      "I've missed more than 9000 shots in my career. "
      "I've lost almost 300 games. 26 times, "
      "I've been trusted to take the game winning shot and missed. "
      "I've failed over and over and over again in my life. "
      "And that is why I succeed.",
      locale: locale);
  String get michaelJordan => Intl.message("Michael Jordan", locale: locale);

  String get missingSpectators => Intl.message(
      "I know I am getting better at golf because I am hitting fewer spectators.",
      locale: locale);
  String get geraldFord => Intl.message("Gerald R. Ford", locale: locale);

  String get dontPanic => Intl.message("Don't Panic", locale: locale);
  String get douglaseAdams => Intl.message("Douglas Adams", locale: locale);

  String confirmdeleteinvite(Invite invite) {
    if (invite is InviteToTeam) {
      InviteToTeam inviteTeam = invite;
      return confirmdeleteinvitetoteam(inviteTeam.teamName);
    }
    return unknown;
  }

  String confirmdeleteinvitetoteam(String teamName) {
    return Intl.message('Do you want to delete the invite to $teamName?',
        args: [teamName],
        desc: 'Text to delete the invite to the team in the alert dialog.',
        name: "confirmdeleteinvitetoteam");
  }

  String teamForInvite(String teamName) => Intl.message("Team $teamName",
      locale: locale, args: [teamName], name: "teamForInvite");
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
