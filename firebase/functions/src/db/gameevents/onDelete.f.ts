import * as functions from "firebase-functions";

export default functions.firestore.document("GameEvents/{gameUid}").onDelete(
  async (
    snapshot: FirebaseFirestore.QueryDocumentSnapshot
  ): Promise<unknown> => {
    const eventType = snapshot.data()?.type;

    switch (eventType) {
      case "Made":
      case "Missed": {
        return snapshot;
      }
      default: {
        return snapshot;
      }
    }
  }
);
