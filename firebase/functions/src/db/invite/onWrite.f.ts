import * as functions from "firebase-functions";
import onCreate from "./onCreate.f";

export default functions.firestore
  .document("Invites/{gameUid}")
  .onWrite(async change => {
    return onCreate(change.after);
  });
