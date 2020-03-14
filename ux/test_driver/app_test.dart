// Imports the Flutter Driver API.
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Basketball Stats Main Page', () {
    final contentSection = find.byValueKey('teamsContent');
    final buttonFinder = find.byTooltip('Add Team');
    //final config = Config();
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

      // await screenshot(driver, config, "noteams");
    });

    test('add team', () async {
      // Waif for the screen to load.
      await driver.waitFor(find.text("No Teams"));

      // First, tap the button.
      await driver.tap(buttonFinder);

      print("Clicking button");

      // Wait for the editbox for the name to show up.
      await driver.waitFor(find.text("Add Team"));
      //await driver.waitFor(saveButtonFinder);

      print("Team Name");

      var tree = await driver.getRenderTree();
      print(tree.toJson());

      //await screenshot(driver, config, "addteamdialog");

      print("After screenshot");

      await driver.enterText("Frog");

      print("Stuff");
      print(driver.getRenderTree());

      await driver.tap(saveButtonFinder);

      print("Save button");

      await driver.waitFor(contentSection);

      print("content");

      await driver.waitFor(find.text("Frog"));

      //await screenshot(driver, config, "singleteam");
    });
  });
}
