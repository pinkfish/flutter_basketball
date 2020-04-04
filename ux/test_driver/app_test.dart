// Imports the Flutter Driver API.
import 'package:flutter_driver/flutter_driver.dart';
import 'package:screenshots/screenshots.dart';
import 'package:test/test.dart';

void main() {
  Future<void> delayStuff([int milliseconds = 250]) async {
    await Future<void>.delayed(Duration(milliseconds: milliseconds));
  }

  group('Basketball Stats Main Page', () {
    final contentSection = find.byValueKey('teamsContent');
    final addTeamButtonFinder = find.byTooltip('Add Team');
    final config = Config();
    final saveButtonFinder = find.byValueKey('saveButtonTeam');

    FlutterDriver driver;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('No teams', () async {
      await driver.waitFor(find.text("No Teams"));

      await screenshot(driver, config, "noteams",
          waitUntilNoTransientCallbacks: false);
    });

    test('single team', () async {
      // Waif for the screen to load.
      await driver.waitFor(find.text("No Teams"));

      // First, tap the button.
      await driver.tap(addTeamButtonFinder);

      await delayStuff(500);

      print("Clicking button");

      // Wait for the editbox for the name to show up.
      await driver.runUnsynchronized(() => driver.waitFor(saveButtonFinder));

      print("Team Name");

      screenshot(driver, config, "addteamdialog",
          waitUntilNoTransientCallbacks: false);

      print("After screenshot");

      await driver.runUnsynchronized(
          () => driver.tap(find.byValueKey("teamFormField")));

      print("Enter team");

      await driver.enterText("Frog");

      print("Select season");

      await driver.runUnsynchronized(
          () => driver.tap(find.byValueKey("seasonFormField")));

      print("Enter season");
      await driver.enterText("2020");

      print("Saving...");
      await driver.runUnsynchronized(() => driver.tap(saveButtonFinder));

      print("Save button");

      await driver.runUnsynchronized(() => driver.waitFor(contentSection));

      print("content");

      await driver.runUnsynchronized(() => driver.waitFor(find.text("Frog")));

      await screenshot(driver, config, "singleteam",
          waitUntilNoTransientCallbacks: false);

      // Open the team itself.
    });
  });
}
