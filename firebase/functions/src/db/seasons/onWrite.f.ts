import * as functions from "firebase-functions";
const admin = require("firebase-admin");
const db = admin.firestore();

export const updateSeasonSummary = functions.firestore
  .document("Games/{gameUid}")
  .onWrite((change, context) => {
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

    // Both finished so we don't do anything.
    if (afterSummary.finished == beforeSummary.finished) {
      return;
    }

    // Get all the games for the season and add it all up.
    const query = db.collection("Games").where("teamUid", "==", teamUid);

    return query.get().then((snap: FirebaseFirestore.QuerySnapshot) => {
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

      // Update the season with the result.
      db.collection("Seasons")
        .doc(teamUid)
        .update({
          ptsFor: ptsFor,
          ptsAgainst: ptsAgainst,
          wins: win,
          losses: loss,
          ties: tie
        });
    });
  });
