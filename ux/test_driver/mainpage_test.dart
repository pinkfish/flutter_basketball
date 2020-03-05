// Imports the Flutter Driver API.
import 'package:flutter_driver/flutter_driver.dart';
import 'package:screenshots/screenshots.dart';
import 'package:test/test.dart';

void main() {
  group('Basketball Stats Main Page', () {
    final contentSection = find.byValueKey('teamsContent');
    final buttonFinder = find.byTooltip('Add Team');
    final config = Config();
    final saveButtonFinder = find.byValueKey('saveButton');
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

      await screenshot(driver, config, "noteams");
    });

    test('add team', () async {
      // Waif for the screen to load.
      await driver.waitFor(find.text("No Teams"));

      // First, tap the button.
      await driver.tap(buttonFinder);

      // Wait for the editbox for the name to show up.
      await driver.waitFor(find.text("Team Name"));

      await screenshot(driver, config, "addteamdialog");

      await driver.enterText("Frog");

      await driver.tap(saveButtonFinder);

      await driver.waitFor(contentSection);

      await driver.waitFor(find.text("Frog"));

      await screenshot(driver, config, "singleteam");
    });
  });
}
