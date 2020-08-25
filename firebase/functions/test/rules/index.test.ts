import * as firebase from "@firebase/testing";
import * as fs from "fs";

/*
 * ============
 *    Setup
 * ============
 */
const projectName = "test-basketballstats";
const coverageUrl = `http://localhost:9090/emulator/v1/projects/${projectName}:ruleCoverage.html`;

const rules = fs.readFileSync("../firestore.rules", "utf8");

interface UserData {
  uid: string;
  email: string;
  name: string;
}

const allowedUserId: string = "alice";
const allowedUserData: UserData = {
  uid: allowedUserId,
  email: "alice@alice.com",
  name: "Alice Luthor"
};

/**
 * Creates a new app with authentication data matching the input.
 */
function authedApp(auth: UserData | undefined) {
  return firebase
    .initializeTestApp({ projectId: projectName, auth: auth as object })
    .firestore();
}

async function createLex() {
  const dbLuthor = authedApp({
    uid: "lex",
    name: "Lex Luthor",
    email: "lex@example.com"
  });
  await firebase.assertSucceeds(
    dbLuthor
      .collection("Users")
      .doc("lex")
      .set({ email: "lex@example.com", name: "Lex Luthor" })
  );
  await firebase.assertSucceeds(
    dbLuthor
      .collection("Teams")
      .doc("other")
      .set({ users: { lex: { enabled: true } } })
  );
  return dbLuthor;
}

describe("Firebase rules", () => {
  beforeEach(async () => {
    console.log("clearFirestoreData");
    // Clear the database between tests
    await firebase.clearFirestoreData({
      projectId: projectName
    });
    // Setup some basic data.
    const db = authedApp(allowedUserData);
    console.log("setup user");
    await db
      .collection("Users")
      .doc(allowedUserId)
      .set({ email: "alice@luther.com", name: "Alice Luthor" });
    console.log("end beforeEach");
  });

  before(async () => {
    console.log("start before");
    await firebase.loadFirestoreRules({
      projectId: projectName,
      rules: rules
    });
    console.log("end before");
  });

  after(async () => {
    await Promise.all(firebase.apps().map(app => app.delete()));
    console.log(`View rule coverage information at ${coverageUrl}\n`);
  });

  it("Teams.get - needs auth", async () => {
    const db = authedApp(undefined);
    const doc = db.collection("Teams").doc("frog");
    await firebase.assertFails(doc.get());
  });
  it("Invites.get - needs auth", async () => {
    const db = authedApp(undefined);
    const doc = db.collection("Invites").doc("frog");
    await firebase.assertFails(doc.get());
  });
  it("Games.get - needs auth", async () => {
    const db = authedApp(undefined);
    const doc = db.collection("Games").doc("frog");
    await firebase.assertFails(doc.get());
  });
  it("GameEvents.get - needs auth", async () => {
    const db = authedApp(undefined);
    const doc = db.collection("GameEvents").doc("frog");
    await firebase.assertFails(doc.get());
  });
  it("Media.get - needs auth", async () => {
    const db = authedApp(undefined);
    const doc = db.collection("Media").doc("frog");
    await firebase.assertFails(doc.get());
  });

  it("Seasons.get - needs auth", async () => {
    const db = authedApp(undefined);
    const doc = db.collection("Seasons").doc("frog");
    await firebase.assertFails(doc.get());
  });

  it("Players.get - needs auth", async () => {
    const db = authedApp(undefined);
    const doc = db.collection("Players").doc("frog");
    await firebase.assertFails(doc.get());
  });

  it("Users.get - needs auth", async () => {
    const db = authedApp(undefined);
    const doc = db.collection("Users").doc("frog");
    await firebase.assertFails(doc.get());
  });

  it("getAllTeams works", async () => {
    await createLex();
    const db = authedApp(allowedUserData);
    await firebase.assertSucceeds(
      db
        .collection("Teams")
        .doc("frog")
        .set({ users: { alice: { enabled: true } } })
    );
    await firebase.assertSucceeds(
      db
        .collection("Teams")
        .where("users.alice.enabled", "==", "true")
        .get()
    );
  });

  it("Users.get - auth == uid", async () => {
    const db = authedApp(allowedUserData);
    const dbLex = await createLex();

    await firebase.assertSucceeds(
      db
        .collection("Users")
        .doc("alice")
        .get()
    );
    await firebase.assertSucceeds(
      dbLex
        .collection("Users")
        .doc("lex")
        .get()
    );
    await firebase.assertSucceeds(
      db
        .collection("Users")
        .doc("lex")
        .get()
    );
    await firebase.assertFails(
      dbLex
        .collection("Users")
        .doc("alice")
        .update({ red: "yes" })
    );
    await firebase.assertFails(
      db
        .collection("Users")
        .doc("lex")
        .update({ red: "yes" })
    );
    await firebase.assertSucceeds(
      dbLex
        .collection("Users")
        .doc("lex")
        .update({ red: "yes" })
    );
    await firebase.assertSucceeds(
      db
        .collection("Users")
        .doc("alice")
        .update({ red: "yes" })
    );
  });

  it("Teams.get -- uid in users", async () => {
    const dbLex = await createLex();
    const db = authedApp(allowedUserData);
    await firebase.assertSucceeds(
      db
        .collection("Teams")
        .doc("frog")
        .set({ users: { alice: { enabled: true } } })
    );
    //const doc = db.collection("Teams").doc("frog");
    await firebase.assertSucceeds(
      db
        .collection("Teams")
        .doc("frog")
        .get()
    );
    await firebase.assertFails(
      db
        .collection("Teams")
        .doc("rabbit")
        .get()
    );
    await firebase.assertFails(
      db
        .collection("Teams")
        .doc("other")
        .get()
    );

    // Add our user into the dbLex team
    await firebase.assertSucceeds(
      dbLex
        .collection("Teams")
        .doc("other")
        .update({ "users.alice.enabled": true })
    );
    await firebase.assertSucceeds(
      db
        .collection("Teams")
        .doc("other")
        .get()
    );
  });
});
