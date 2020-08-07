// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars

class S {
  S();
  
  static S current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S.current = S();
      
      return S.current;
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  // skipped getter for the 'Basketball stats' key

  // skipped getter for the 'Loading...' key

  // skipped getter for the 'Add Team' key

  // skipped getter for the 'Sign in with Google' key

  // skipped getter for the 'Add User' key

  /// `GUEST`
  String get GUEST {
    return Intl.message(
      'GUEST',
      name: 'GUEST',
      desc: 'Button text for adding a guest player',
      args: [],
    );
  }

  // skipped getter for the 'Guest players' key

  /// `Details`
  String get Details {
    return Intl.message(
      'Details',
      name: 'Details',
      desc: 'Description of the form flow that has the game details',
      args: [],
    );
  }

  // skipped getter for the 'No guest players' key

  // skipped getter for the 'All Seasons' key

  // skipped getter for the 'All Players' key

  /// `Summary`
  String get Summary {
    return Intl.message(
      'Summary',
      name: 'Summary',
      desc: 'Title for the page showing the add game summary',
      args: [],
    );
  }

  // skipped getter for the 'Add Season' key

  /// `SEASON`
  String get SEASON {
    return Intl.message(
      'SEASON',
      name: 'SEASON',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the 'Edit Team' key

  // skipped getter for the 'Edit Player' key

  /// `Users`
  String get Users {
    return Intl.message(
      'Users',
      name: 'Users',
      desc: 'Title of the users section in the team details',
      args: [],
    );
  }

  // skipped getter for the 'Add Game' key

  // skipped getter for the 'Add Player' key

  // skipped getter for the 'No Teams' key

  // skipped getter for the 'No Games' key

  // skipped getter for the 'No Seasons' key

  // skipped getter for the 'No Players' key

  /// `UI`
  String get UI {
    return Intl.message(
      'UI',
      name: 'UI',
      desc: 'Settings header for the UI settings',
      args: [],
    );
  }

  // skipped getter for the 'Invite to Team' key

  // skipped getter for the 'Light mode' key

  // skipped getter for the 'No Players with state' key

  /// `About`
  String get About {
    return Intl.message(
      'About',
      name: 'About',
      desc: 'Menu item to open information about the app',
      args: [],
    );
  }

  // skipped getter for the 'Do you want to finish streaming the game?' key

  // skipped getter for the 'Failed to create thumbnail for the stream' key

  // skipped getter for the 'Video Steaming' key

  /// `Settings`
  String get Settings {
    return Intl.message(
      'Settings',
      name: 'Settings',
      desc: 'Menu item to open information settings of the app',
      args: [],
    );
  }

  // skipped getter for the 'Event Time' key

  // skipped getter for the 'Team Name' key

  // skipped getter for the 'Season Name' key

  // skipped getter for the 'Player Name' key

  /// `Opponent`
  String get Opponent {
    return Intl.message(
      'Opponent',
      name: 'Opponent',
      desc: 'The opponent in the game',
      args: [],
    );
  }

  /// `Location`
  String get Location {
    return Intl.message(
      'Location',
      name: 'Location',
      desc: 'Location of the game',
      args: [],
    );
  }

  // skipped getter for the 'Jersey Number' key

  // skipped getter for the 'Must not be empty' key

  // skipped getter for the 'Error in the form' key

  // skipped getter for the 'Save Failed' key

  /// `SAVE`
  String get SAVE {
    return Intl.message(
      'SAVE',
      name: 'SAVE',
      desc: 'Text on a save button',
      args: [],
    );
  }

  /// `STATS`
  String get STATS {
    return Intl.message(
      'STATS',
      name: 'STATS',
      desc: 'Text on a stats button',
      args: [],
    );
  }

  /// `GAMES`
  String get GAMES {
    return Intl.message(
      'GAMES',
      name: 'GAMES',
      desc: 'Text on a games button',
      args: [],
    );
  }

  /// `EDIT`
  String get EDIT {
    return Intl.message(
      'EDIT',
      name: 'EDIT',
      desc: 'Text on a edit button',
      args: [],
    );
  }

  /// `END`
  String get END {
    return Intl.message(
      'END',
      name: 'END',
      desc: 'Text on a end button',
      args: [],
    );
  }

  /// `FOUL`
  String get FOUL {
    return Intl.message(
      'FOUL',
      name: 'FOUL',
      desc: 'Text on the foul button',
      args: [],
    );
  }

  // skipped getter for the 'T/O' key

  /// `BLK`
  String get BLK {
    return Intl.message(
      'BLK',
      name: 'BLK',
      desc: 'Block button',
      args: [],
    );
  }

  /// `ASST`
  String get ASST {
    return Intl.message(
      'ASST',
      name: 'ASST',
      desc: 'Assist button',
      args: [],
    );
  }

  /// `STL`
  String get STL {
    return Intl.message(
      'STL',
      name: 'STL',
      desc: 'Steal button',
      args: [],
    );
  }

  // skipped getter for the 'DEF RB' key

  // skipped getter for the 'OFF RB' key

  /// `SUB`
  String get SUB {
    return Intl.message(
      'SUB',
      name: 'SUB',
      desc: 'Text on a substitution button',
      args: [],
    );
  }

  /// `PLAYER`
  String get PLAYER {
    return Intl.message(
      'PLAYER',
      name: 'PLAYER',
      desc: 'Text on a add player button',
      args: [],
    );
  }

  /// `START`
  String get START {
    return Intl.message(
      'START',
      name: 'START',
      desc: 'Text on a button to start the period',
      args: [],
    );
  }

  /// `GAME`
  String get GAME {
    return Intl.message(
      'GAME',
      name: 'GAME',
      desc: 'Text on a add game button',
      args: [],
    );
  }

  /// `TEAM`
  String get TEAM {
    return Intl.message(
      'TEAM',
      name: 'TEAM',
      desc: 'Text on a add team button',
      args: [],
    );
  }

  /// `unknown`
  String get unknown {
    return Intl.message(
      'unknown',
      name: 'unknown',
      desc: 'Used when the data is unknown',
      args: [],
    );
  }

  // skipped getter for the 'All Periods' key

  /// `Timeline`
  String get Timeline {
    return Intl.message(
      'Timeline',
      name: 'Timeline',
      desc: 'Bottom navigation to open the timeline',
      args: [],
    );
  }

  /// `Events`
  String get Events {
    return Intl.message(
      'Events',
      name: 'Events',
      desc: 'Bottom navigation to open the events',
      args: [],
    );
  }

  /// `Stats`
  String get Stats {
    return Intl.message(
      'Stats',
      name: 'Stats',
      desc: 'Used when the data is unknown',
      args: [],
    );
  }

  /// `Players`
  String get Players {
    return Intl.message(
      'Players',
      name: 'Players',
      desc: 'Used when the data is unknown',
      args: [],
    );
  }

  /// `Video`
  String get Video {
    return Intl.message(
      'Video',
      name: 'Video',
      desc: 'Shows video for the game',
      args: [],
    );
  }

  // skipped getter for the 'Select Media' key

  // skipped getter for the 'Upload Video' key

  /// `Photo`
  String get Photo {
    return Intl.message(
      'Photo',
      name: 'Photo',
      desc: 'Upload a photo',
      args: [],
    );
  }

  // skipped getter for the 'Stream Live' key

  /// `CAMERA`
  String get CAMERA {
    return Intl.message(
      'CAMERA',
      name: 'CAMERA',
      desc: 'Live video streaming',
      args: [],
    );
  }

  /// `GALLERY`
  String get GALLERY {
    return Intl.message(
      'GALLERY',
      name: 'GALLERY',
      desc: 'Live video streaming',
      args: [],
    );
  }

  // skipped getter for the 'No Media' key

  /// `STREAM`
  String get STREAM {
    return Intl.message(
      'STREAM',
      name: 'STREAM',
      desc: 'Button to display a stream',
      args: [],
    );
  }

  /// `UPLOAD`
  String get UPLOAD {
    return Intl.message(
      'UPLOAD',
      name: 'UPLOAD',
      desc: 'Button to display upload a stream',
      args: [],
    );
  }

  // skipped getter for the 'Delete Player' key

  // skipped getter for the 'End timeout' key

  /// `Period`
  String get Period {
    return Intl.message(
      'Period',
      name: 'Period',
      desc: 'Dialog title for sertting the current period',
      args: [],
    );
  }

  /// `PERIOD`
  String get PERIOD {
    return Intl.message(
      'PERIOD',
      name: 'PERIOD',
      desc: 'Button to set the current period',
      args: [],
    );
  }

  // skipped getter for the 'You must have some players in a season to be able to create a game.' key

  // skipped getter for the 'Name is required.' key

  // skipped getter for the 'Email is required.' key

  // skipped getter for the 'Invalid email' key

  // skipped getter for the 'Empty password' key

  // skipped getter for the 'Password must be 6 characters long' key

  /// `Email`
  String get Email {
    return Intl.message(
      'Email',
      name: 'Email',
      desc: 'Email hint text',
      args: [],
    );
  }

  // skipped getter for the 'FORGOT PASSWORD' key

  // skipped getter for the 'Sent email to your email address to reset your password' key

  // skipped getter for the 'The users who have access to this team, they can see the stats and edit the team/seasons/players.' key

  // skipped getter for the 'The email to resend the password to' key

  // skipped getter for the 'RESEND EMAIL' key

  /// `LOGIN`
  String get LOGIN {
    return Intl.message(
      'LOGIN',
      name: 'LOGIN',
      desc: 'Login button text',
      args: [],
    );
  }

  /// `LOGOUT`
  String get LOGOUT {
    return Intl.message(
      'LOGOUT',
      name: 'LOGOUT',
      desc: 'Logout button text',
      args: [],
    );
  }

  /// `CREATE`
  String get CREATE {
    return Intl.message(
      'CREATE',
      name: 'CREATE',
      desc: 'Create account button text',
      args: [],
    );
  }

  // skipped getter for the 'Contact phone number' key

  // skipped getter for the 'Phone number (optional)' key

  /// `Password`
  String get Password {
    return Intl.message(
      'Password',
      name: 'Password',
      desc: 'Input box for a password',
      args: [],
    );
  }

  // skipped getter for the 'Verify password' key

  // skipped getter for the 'Please fix the items outlined in red' key

  // skipped getter for the 'Email and/or password incorrect' key

  // skipped getter for the 'Internal Error' key

  // skipped getter for the 'Login Cancelled' key

  // skipped getter for the 'Passwords must match' key

  // skipped getter for the 'Created an account, please look in your email for the verification code..' key

  // skipped getter for the 'Your email address' key

  /// `Name`
  String get Name {
    return Intl.message(
      'Name',
      name: 'Name',
      desc: 'Name for the edit box to edit the user name',
      args: [],
    );
  }

  // skipped getter for the 'Your name' key

  // skipped getter for the 'Sent verification email, please check your email inbox.' key

  // skipped getter for the 'No account found for email or internal error occured' key

  /// `Email address {email} needs to be verified, please check your email or resend the verification details.`
  String verifyexplanation(Object email) {
    return Intl.message(
      'Email address $email needs to be verified, please check your email or resend the verification details.',
      name: 'verifyexplanation',
      desc: 'Button to resend the email to verify their email address',
      args: [email],
    );
  }

  // skipped getter for the 'Invalid URL' key

  // skipped getter for the 'Error creating user, maybe the email address is already used' key

  /// `View`
  String get View {
    return Intl.message(
      'View',
      name: 'View',
      desc: 'Title for the tab to show the playing video',
      args: [],
    );
  }

  // skipped getter for the 'Create new' key

  /// `Are you sure you want to delete the player {name}?`
  String deletePlayerAreYouSure(Object name) {
    return Intl.message(
      'Are you sure you want to delete the player $name?',
      name: 'deletePlayerAreYouSure',
      desc: 'Dialog text to ask if you aere sure about deleting the player',
      args: [name],
    );
  }

  /// `Shots`
  String get Shots {
    return Intl.message(
      'Shots',
      name: 'Shots',
      desc: 'Heading for the shots sectionn',
      args: [],
    );
  }

  // skipped getter for the 'All Events' key

  /// `Fouls`
  String get Fouls {
    return Intl.message(
      'Fouls',
      name: 'Fouls',
      desc: 'Drop down menu item for fouls',
      args: [],
    );
  }

  /// `Steals`
  String get Steals {
    return Intl.message(
      'Steals',
      name: 'Steals',
      desc: 'Drop down menu item for steals',
      args: [],
    );
  }

  /// `Turnovers`
  String get Turnovers {
    return Intl.message(
      'Turnovers',
      name: 'Turnovers',
      desc: 'Drop down menu item for turnovers',
      args: [],
    );
  }

  /// `Blocks`
  String get Blocks {
    return Intl.message(
      'Blocks',
      name: 'Blocks',
      desc: 'Drop down menu item for fouls',
      args: [],
    );
  }

  /// `Rebounds`
  String get Rebounds {
    return Intl.message(
      'Rebounds',
      name: 'Rebounds',
      desc: 'Drop down menu item for rebounds',
      args: [],
    );
  }

  /// `Points`
  String get Points {
    return Intl.message(
      'Points',
      name: 'Points',
      desc: 'Drop down menu item for points',
      args: [],
    );
  }

  /// `Seasons`
  String get Seasons {
    return Intl.message(
      'Seasons',
      name: 'Seasons',
      desc: 'Header for the seasons section',
      args: [],
    );
  }

  /// `Current`
  String get Current {
    return Intl.message(
      'Current',
      name: 'Current',
      desc: 'Subtitle to markt he season as current',
      args: [],
    );
  }

  /// `Pts`
  String get Pts {
    return Intl.message(
      'Pts',
      name: 'Pts',
      desc: 'Points abbreviation',
      args: [],
    );
  }

  /// `Stl`
  String get Stl {
    return Intl.message(
      'Stl',
      name: 'Stl',
      desc: 'Steals abbreviation',
      args: [],
    );
  }

  /// `Blk`
  String get Blk {
    return Intl.message(
      'Blk',
      name: 'Blk',
      desc: 'Blocks abbreviation',
      args: [],
    );
  }

  // skipped getter for the '%age' key

  // skipped getter for the 'O/RB' key

  // skipped getter for the 'D/RB' key

  /// `RBs`
  String get RBs {
    return Intl.message(
      'RBs',
      name: 'RBs',
      desc: 'Rebounds in game summary',
      args: [],
    );
  }

  /// `URL`
  String get URL {
    return Intl.message(
      'URL',
      name: 'URL',
      desc: 'Title for the form field to set the url for media',
      args: [],
    );
  }

  /// `Description`
  String get Description {
    return Intl.message(
      'Description',
      name: 'Description',
      desc: 'Title for the description of the media',
      args: [],
    );
  }

  // skipped getter for the 'Delete invite' key

  /// `Invites`
  String get Invites {
    return Intl.message(
      'Invites',
      name: 'Invites',
      desc: 'Title for the screen with the list of current invites',
      args: [],
    );
  }

  // skipped getter for the 'No invites' key

  // skipped getter for the 'Basketball stats is an exciting app to show statsabout basketball games.  It shows nifty graphs and fun stuff' key

  /// `{name} [unverified]`
  String getUnverified(Object name, Object unverified) {
    return Intl.message(
      '$name [unverified]',
      name: 'getUnverified',
      desc: 'If the user is unverified',
      args: [name, unverified],
    );
  }

  /// `Pts {points} Blks {blocks} Stls {steals}`
  String seasonSummaryExpanded(Object points, Object blocks, Object steals) {
    return Intl.message(
      'Pts $points Blks $blocks Stls $steals',
      name: 'seasonSummaryExpanded',
      desc: 'Subtitle to markt he season as current',
      args: [points, blocks, steals],
    );
  }

  /// `Played {numSeasons} seasons`
  String playedSeasons(Object numSeasons) {
    return Intl.message(
      'Played $numSeasons seasons',
      name: 'playedSeasons',
      desc: 'Number of seasons playeed for the team',
      args: [numSeasons],
    );
  }

  /// `Win {wins} Loss {loses}`
  String winLoss(Object wins, Object loses, Object ties) {
    return Intl.message(
      'Win $wins Loss $loses',
      name: 'winLoss',
      desc: 'Number of seasons playeed for the team',
      args: [wins, loses, ties],
    );
  }

  /// `vs {opponent} at {place}`
  String getGameVs(Object opponent, Object place) {
    return Intl.message(
      'vs $opponent at $place',
      name: 'getGameVs',
      desc: 'Heading for a game showing the opponent and the place',
      args: [opponent, place],
    );
  }

  /// `Invited: {numPeopleInvited}`
  String invitedpeople(Object numPeopleInvited) {
    return Intl.message(
      'Invited: $numPeopleInvited',
      name: 'invitedpeople',
      desc: 'Heading showing the number of pending invites',
      args: [numPeopleInvited],
    );
  }

  // skipped getter for the 'Not started' key

  /// `Overtime`
  String get Overtime {
    return Intl.message(
      'Overtime',
      name: 'Overtime',
      desc: 'The game is in overtime',
      args: [],
    );
  }

  // skipped getter for the 'Period 1' key

  // skipped getter for the 'Period 2' key

  // skipped getter for the 'Period 3' key

  // skipped getter for the 'Period 4' key

  /// `Finished`
  String get Finished {
    return Intl.message(
      'Finished',
      name: 'Finished',
      desc: 'The game has finished',
      args: [],
    );
  }

  /// `{points}`
  String madeEventType(Object points) {
    return Intl.message(
      '$points',
      name: 'madeEventType',
      desc: '+num points',
      args: [points],
    );
  }

  /// `Miss {points}`
  String missedEventType(Object points) {
    return Intl.message(
      'Miss $points',
      name: 'missedEventType',
      desc: 'missed num points',
      args: [points],
    );
  }

  /// `Foul`
  String get Foul {
    return Intl.message(
      'Foul',
      name: 'Foul',
      desc: 'Foul on player',
      args: [],
    );
  }

  /// `Subsitution`
  String get Subsitution {
    return Intl.message(
      'Subsitution',
      name: 'Subsitution',
      desc: 'Subsitiution of player',
      args: [],
    );
  }

  // skipped getter for the 'Off Rebound' key

  // skipped getter for the 'Def Rebound' key

  /// `Block`
  String get Block {
    return Intl.message(
      'Block',
      name: 'Block',
      desc: 'Block of a shot',
      args: [],
    );
  }

  /// `Assist`
  String get Assist {
    return Intl.message(
      'Assist',
      name: 'Assist',
      desc: 'Assist a shot',
      args: [],
    );
  }

  /// `Steal`
  String get stealEventType {
    return Intl.message(
      'Steal',
      name: 'stealEventType',
      desc: 'Steal a ball',
      args: [],
    );
  }

  /// `Turnover`
  String get turnOverEventType {
    return Intl.message(
      'Turnover',
      name: 'turnOverEventType',
      desc: 'Caused a turnover',
      args: [],
    );
  }

  /// `Start of {periodName}`
  String periodStart(Object periodName) {
    return Intl.message(
      'Start of $periodName',
      name: 'periodStart',
      desc: 'Start of period',
      args: [periodName],
    );
  }

  /// `End of {periodName}`
  String periodEnd(Object periodName) {
    return Intl.message(
      'End of $periodName',
      name: 'periodEnd',
      desc: 'End of period',
      args: [periodName],
    );
  }

  // skipped getter for the 'Lies, Damn Lies and Statistics' key

  // skipped getter for the 'Mark Twain' key

  // skipped getter for the 'I\'ve missed more than 9000 shots in my career. I\'ve lost almost 300 games. 26 times, I\'ve been trusted to take the game winning shot and missed. I\'ve failed over and over and over again in my life. And that is why I succeed.' key

  // skipped getter for the 'Michael Jordan' key

  // skipped getter for the 'I know I am getting better at golf because I am hitting fewer spectators.' key

  // skipped getter for the 'Gerald R. Ford' key

  // skipped getter for the 'Don\'t Panic' key

  // skipped getter for the 'Douglas Adams' key

  /// `Do you want to delete the invite to {teamName}?`
  String confirmdeleteinvitetoteam(Object teamName) {
    return Intl.message(
      'Do you want to delete the invite to $teamName?',
      name: 'confirmdeleteinvitetoteam',
      desc: 'Text to delete the invite to the team in the alert dialog.',
      args: [teamName],
    );
  }

  /// `Team {teamName}`
  String teamForInvite(Object teamName) {
    return Intl.message(
      'Team $teamName',
      name: 'teamForInvite',
      desc: '',
      args: [teamName],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'messages'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}