import * as functions from "firebase-functions";
import doOnCreate from "./onCreate.f";

export default functions.firestore.document("Invites/{gameUid}").onWrite(
  async (
    change: functions.Change<FirebaseFirestore.DocumentData>
  ): Promise<unknown> => {
    const inviteData = change.after.data();
    return doOnCreate(change.after.id, inviteData);
  }
);
