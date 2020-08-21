import * as functions from "firebase-functions";
import onCreate from "./onCreate.f";

export default functions.firestore
  .document("Games/{gameUid}")
  .onWrite(async change => {
    return onCreate(change.after);
  });
