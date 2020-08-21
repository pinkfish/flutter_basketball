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

async function createLex(): Promise<unknown> {
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
  return;
}

describe("My app", () => {
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

  it("require users to log in before listing teams", async () => {
    const db = authedApp(undefined);
    const doc = db.collection("Teams").doc("frog");
    await firebase.assertFails(doc.get());
  });
  it("require users to log in before listing invites", async () => {
    const db = authedApp(undefined);
    const doc = db.collection("Invites").doc("frog");
    await firebase.assertFails(doc.get());
  });
  it("require users to log in before listing games", async () => {
    const db = authedApp(undefined);
    const doc = db.collection("Games").doc("frog");
    await firebase.assertFails(doc.get());
  });
  it("require users to log in before listing games events", async () => {
    const db = authedApp(undefined);
    const doc = db.collection("GameEvents").doc("frog");
    await firebase.assertFails(doc.get());
  });
  it("require users to log in before listing media", async () => {
    const db = authedApp(undefined);
    const doc = db.collection("Media").doc("frog");
    await firebase.assertFails(doc.get());
  });

  it("require users to log in before listing media", async () => {
    const db = authedApp(undefined);
    const doc = db.collection("Media").doc("frog");
    await firebase.assertFails(doc.get());
  });

  it("require users to log in before listing seasons", async () => {
    const db = authedApp(undefined);
    const doc = db.collection("Seasons").doc("frog");
    await firebase.assertFails(doc.get());
  });

  it("require users to log in before listing players", async () => {
    const db = authedApp(undefined);
    const doc = db.collection("Players").doc("frog");
    await firebase.assertFails(doc.get());
  });

  it("require users to log in before listing users", async () => {
    const db = authedApp(undefined);
    const doc = db.collection("Users").doc("frog");
    await firebase.assertFails(doc.get());
  });

  /*
  it("require users to be in the season to get season", async () => {
    const db = authedApp(allowedUserData);
    db.collection("Teams")
      .doc("frog")
      .set({ user: { alice: { added: true } } });
    //const doc = db.collection("Teams").doc("frog");
    await firebase.assertSucceeds(
      db
        .collection("Teams")
        .doc("frog")
        .get()
    );
  });
  */

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

  it("require users to be in the teams to get team", async () => {
    await createLex();
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
  });

  /*
  it("require users to be in the season to get the season", async () => {
    const db = authedApp(allowedUserData);
    await firebase.assertSucceeds(
      db
        .collection("Seasons")
        .doc("frog")
        .set({ user: { alice: { added: true } } })
    );
    //const doc = db.collection("Teams").doc("frog");
    await firebase.assertSucceeds(
      db
        .collection("Seasons")
        .doc("frog")
        .get()
    );
  });
  it("should enforce the createdAt date in user profiles", async () => {
    const db = authedApp(allowedUserData);
    const profile = db.collection("UserData").doc("alice");
    await firebase.assertFails(profile.set({ birthday: "January 1" }));
    await firebase.assertSucceeds(
      profile.set({
        birthday: "January 1",
        createdAt: firebase.firestore.FieldValue.serverTimestamp()
      })
    );
  });
  */
});
