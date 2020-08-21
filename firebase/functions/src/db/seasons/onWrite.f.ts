import * as functions from "firebase-functions";
import * as c from "../../util/constants";
import admin from "firebase-admin";
try {
  admin.initializeApp(c.FIREBASE_APP_OPTIONS);
} catch (e) {
  if (e.errorInfo.code !== "app/duplicate-app") {
    console.log(e);
  }
}
const db = admin.firestore();

export default functions.firestore.document("Games/{gameUid}").onWrite(
  async (
    change: functions.Change<FirebaseFirestore.DocumentData>
  ): Promise<unknown> => {
    // If it didn't exist or still exists then we update.
    const beforeSummary = change.before.exists
      ? change.before.data()?.summary
      : { finished: false, pointsFor: 0, pointsAgainst: 0 };
    const afterSummary = change.after.exists
      ? change.after.data()?.summary
      : { finished: false, pointsFor: 0, pointsAgainst: 0 };
    const teamUid = change.before.exists
      ? change.before.data()?.teamUid
      : change.after.exists
      ? change.after.data()?.teamUid
      : "";
    const seasonUid = change.before.exists
      ? change.before.data()?.seasonUid
      : change.after.exists
      ? change.after.data()?.seasonUid
      : "";

    // Both finished so we don't do anything.
    if (
      afterSummary.finished == beforeSummary.finished &&
      afterSummary.ptsAgainst == beforeSummary.ptsAgainst &&
      afterSummary.ptsFor == beforeSummary.ptsFor
    ) {
      console.log("Both states are finished");
      return false;
    }

    try {
      // Get all the games for the season and add it all up.
      const query = db.collection("Games").where("teamUid", "==", teamUid);

      const snap = await query.get();

      let win = 0;
      let loss = 0;
      let ptsFor = 0;
      let ptsAgainst = 0;
      let tie = 0;

      // Go through the documents to find stuff.
      for (const documentSnapshot of snap.docs) {
        if (documentSnapshot.data().summary.finished) {
          if (
            documentSnapshot.data().summary.ptsFor >
            documentSnapshot.data().summary.ptsAgainst
          ) {
            win++;
          } else if (
            documentSnapshot.data().summary.ptsAgainst >
            documentSnapshot.data().summary.ptsFor
          ) {
            loss++;
          } else {
            tie++;
          }
          ptsFor += documentSnapshot.data().summary.ptsFor;
          ptsAgainst += documentSnapshot.data().summary.ptsAgainst;
        }
      }

      const doc = await db
        .collection("Seasons")
        .doc(seasonUid)
        .get();
      if (!doc.exists) {
        console.log("Not able to find season ", seasonUid);
        return Promise.resolve(false);
      }

      const seasonSummary = doc.exists
        ? doc.data()?.summary
        : { ptsFor: 0, ptsAgainst: 0, wins: 0, losses: 0, ties: 0 };

      if (
        seasonSummary.ptsFor !== ptsFor ||
        seasonSummary.ptsAgainst !== ptsAgainst ||
        seasonSummary.wins !== win ||
        seasonSummary.losses !== loss ||
        seasonSummary.ties !== tie
      ) {
        // Update the season with the result.
        await db
          .collection("Seasons")
          .doc(seasonUid)
          .update({
            summary: {
              ptsFor: ptsFor,
              ptsAgainst: ptsAgainst,
              wins: win,
              losses: loss,
              ties: tie
            }
          });
      }
      console.log("No change for season ", seasonUid);
      return true;
    } catch (error) {
      console.log("Error with media ", error);
      return false;
    }
  }
);
