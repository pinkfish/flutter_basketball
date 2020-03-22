import * as functions from "firebase-functions";

export  default functions.firestore
  .document("GameEvents/{gameUid}")
  .onDelete((snapshot) => {
  return snapshot;
  /*
  const eventType = snapshot.data()?.type;
  const opponent = snapshot.data()?.opponent;
  const gameRef = db.collection('Games').doc(snapshot.data()?.gameUid);
  const points = snapshot.data()?.points;
  const period = snapshot.data()?.period;
  const playerUid = snapshot.data()?.playerUid;

  switch (eventType) {
    case 'Made':
    case 'Missed': {
      let transaction = db.runTransaction(t => {
         return t.get(gameRef)
           .then(doc => {
             if (opponent) {
               const newPtsAgainst = doc.data().pointsAgainst + points;
               t.update(gameRef, {'summary.pointsAgainst': newPopulation});
               // Update the player data too.
               const perPeriod = doc.data().playerUids[playerUid].perPeriod[period];
               if (points == 1) {
                 const newMade = perPeriod.one.made + (eventType == 'Made' ? 1 : 0);
                 const newAttempts = perPeriod.one.attempts + 1;
                 t.update(gameRef, {
                 'playerUids.' + playerUid + '.perPeriod.' + period + '.one.made': newMade,
                 'playerUids.' + playerUid + '.perPeriod.' + period + '.one.attempts': newAttempts,
                 });
               } else if (points == 2) {
                 const newMade = perPeriod.one.made + (eventType == 'Made' ? 1 : 0);
                 const newAttempts = perPeriod.one.attempts + 1;
                 t.update(gameRef, {'summary.pointsAgainst': newPopulation});
               } else if (points == 3) {
                 const newMade = perPeriod.one.made + (eventType == 'Made' ? 1 : 0);
                 const newAttempts = perPeriod.one.attempts + 1;
                 t.update(gameRef, {'summary.pointsAgainst': newPopulation});
               }
             } else {
               const newPtsFor = doc.data().pointsFor + points;
               t.update(gameRef, {'summary.pointsFor': newPopulation});
               // Update the player data too.
               const perPeriod = doc.data().playerUids[playerUid].perPeriod[doc.data().currentPeriod];
               if (points == 1) {
               } else if (points == 2) {
               } else if (points == 3) {
               }
             }
           });
       }).then(result => {
         console.log('Transaction success!');
       }).catch(err => {
         console.log('Transaction failure:', err);
       });
      return snapshot;
    }
    default: {
      return snapshot;
    }
  }
  */
});