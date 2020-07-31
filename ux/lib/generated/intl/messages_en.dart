// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static m0(teamName) => "Do you want to delete the invite to ${teamName}?";

  static m1(name) => "Are you sure you want to delete the player ${name}?";

  static m2(opponent, place) => "vs ${opponent} at ${place}";

  static m3(name, unverified) => "${name} [unverified]";

  static m4(numPeopleInvited) => "Invited: ${numPeopleInvited}";

  static m5(points) => "${points}";

  static m6(points) => "Miss ${points}";

  static m7(periodName) => "End of ${periodName}";

  static m8(periodName) => "Start of ${periodName}";

  static m9(numSeasons) => "Played ${numSeasons} seasons";

  static m10(points, blocks, steals) => "Pts ${points} Blks ${blocks} Stls ${steals}";

  static m11(teamName) => "Team ${teamName}";

  static m12(email) => "Email address ${email} needs to be verified, please check your email or resend the verification details.";

  static m13(wins, loses, ties) => "Win ${wins} Loss ${loses}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "ASST" : MessageLookupByLibrary.simpleMessage("ASST"),
    "About" : MessageLookupByLibrary.simpleMessage("About"),
    "Assist" : MessageLookupByLibrary.simpleMessage("Assist"),
    "BLK" : MessageLookupByLibrary.simpleMessage("BLK"),
    "Blk" : MessageLookupByLibrary.simpleMessage("Blk"),
    "Block" : MessageLookupByLibrary.simpleMessage("Block"),
    "Blocks" : MessageLookupByLibrary.simpleMessage("Blocks"),
    "CAMERA" : MessageLookupByLibrary.simpleMessage("CAMERA"),
    "CREATE" : MessageLookupByLibrary.simpleMessage("CREATE"),
    "Current" : MessageLookupByLibrary.simpleMessage("Current"),
    "Description" : MessageLookupByLibrary.simpleMessage("Description"),
    "Details" : MessageLookupByLibrary.simpleMessage("Details"),
    "EDIT" : MessageLookupByLibrary.simpleMessage("EDIT"),
    "END" : MessageLookupByLibrary.simpleMessage("END"),
    "Email" : MessageLookupByLibrary.simpleMessage("Email"),
    "Events" : MessageLookupByLibrary.simpleMessage("Events"),
    "FOUL" : MessageLookupByLibrary.simpleMessage("FOUL"),
    "Finished" : MessageLookupByLibrary.simpleMessage("Finished"),
    "Foul" : MessageLookupByLibrary.simpleMessage("Foul"),
    "Fouls" : MessageLookupByLibrary.simpleMessage("Fouls"),
    "GALLERY" : MessageLookupByLibrary.simpleMessage("GALLERY"),
    "GAME" : MessageLookupByLibrary.simpleMessage("GAME"),
    "GAMES" : MessageLookupByLibrary.simpleMessage("GAMES"),
    "GUEST" : MessageLookupByLibrary.simpleMessage("GUEST"),
    "Invites" : MessageLookupByLibrary.simpleMessage("Invites"),
    "LOGIN" : MessageLookupByLibrary.simpleMessage("LOGIN"),
    "LOGOUT" : MessageLookupByLibrary.simpleMessage("LOGOUT"),
    "Location" : MessageLookupByLibrary.simpleMessage("Location"),
    "Name" : MessageLookupByLibrary.simpleMessage("Name"),
    "Opponent" : MessageLookupByLibrary.simpleMessage("Opponent"),
    "Overtime" : MessageLookupByLibrary.simpleMessage("Overtime"),
    "PERIOD" : MessageLookupByLibrary.simpleMessage("PERIOD"),
    "PLAYER" : MessageLookupByLibrary.simpleMessage("PLAYER"),
    "Password" : MessageLookupByLibrary.simpleMessage("Password"),
    "Period" : MessageLookupByLibrary.simpleMessage("Period"),
    "Photo" : MessageLookupByLibrary.simpleMessage("Photo"),
    "Players" : MessageLookupByLibrary.simpleMessage("Players"),
    "Points" : MessageLookupByLibrary.simpleMessage("Points"),
    "Pts" : MessageLookupByLibrary.simpleMessage("Pts"),
    "RBs" : MessageLookupByLibrary.simpleMessage("RBs"),
    "Rebounds" : MessageLookupByLibrary.simpleMessage("Rebounds"),
    "SAVE" : MessageLookupByLibrary.simpleMessage("SAVE"),
    "SEASON" : MessageLookupByLibrary.simpleMessage("SEASON"),
    "START" : MessageLookupByLibrary.simpleMessage("START"),
    "STATS" : MessageLookupByLibrary.simpleMessage("STATS"),
    "STL" : MessageLookupByLibrary.simpleMessage("STL"),
    "STREAM" : MessageLookupByLibrary.simpleMessage("STREAM"),
    "SUB" : MessageLookupByLibrary.simpleMessage("SUB"),
    "Seasons" : MessageLookupByLibrary.simpleMessage("Seasons"),
    "Settings" : MessageLookupByLibrary.simpleMessage("Settings"),
    "Shots" : MessageLookupByLibrary.simpleMessage("Shots"),
    "Stats" : MessageLookupByLibrary.simpleMessage("Stats"),
    "Steals" : MessageLookupByLibrary.simpleMessage("Steals"),
    "Stl" : MessageLookupByLibrary.simpleMessage("Stl"),
    "Subsitution" : MessageLookupByLibrary.simpleMessage("Subsitution"),
    "Summary" : MessageLookupByLibrary.simpleMessage("Summary"),
    "TEAM" : MessageLookupByLibrary.simpleMessage("TEAM"),
    "Timeline" : MessageLookupByLibrary.simpleMessage("Timeline"),
    "Turnovers" : MessageLookupByLibrary.simpleMessage("Turnovers"),
    "UI" : MessageLookupByLibrary.simpleMessage("UI"),
    "UPLOAD" : MessageLookupByLibrary.simpleMessage("UPLOAD"),
    "URL" : MessageLookupByLibrary.simpleMessage("URL"),
    "Users" : MessageLookupByLibrary.simpleMessage("Users"),
    "Video" : MessageLookupByLibrary.simpleMessage("Video"),
    "View" : MessageLookupByLibrary.simpleMessage("View"),
    "confirmdeleteinvitetoteam" : m0,
    "deletePlayerAreYouSure" : m1,
    "getGameVs" : m2,
    "getUnverified" : m3,
    "invitedpeople" : m4,
    "madeEventType" : m5,
    "missedEventType" : m6,
    "periodEnd" : m7,
    "periodStart" : m8,
    "playedSeasons" : m9,
    "seasonSummaryExpanded" : m10,
    "stealEventType" : MessageLookupByLibrary.simpleMessage("Steal"),
    "teamForInvite" : m11,
    "turnOverEventType" : MessageLookupByLibrary.simpleMessage("Turnover"),
    "unknown" : MessageLookupByLibrary.simpleMessage("unknown"),
    "verifyexplanation" : m12,
    "winLoss" : m13
  };
}
