import * as functions from "firebase-functions";
import axios from "axios";
import admin from "firebase-admin";
import * as c from "../util/constants";
import { firestore } from "firebase-admin";
try {
  admin.initializeApp(c.FIREBASE_APP_OPTIONS);
} catch (e) {
  if (e.errorInfo.code !== "app/duplicate-app") {
    console.log(e);
  }
}

const db = admin.firestore();

const api = axios.create({
  timeout: 3000,
  headers: {
    common: {
      "Content-Type": "application/json"
    }
  }
});
api.interceptors.request.use(request => {
  console.log("Starting Request", request);
  return request;
});
api.interceptors.response.use(response => {
  console.log("Response", response);
  return response;
});

interface RequestData {
  gameUid: string;
  teamUid: string;
  seasonUid: string;
}

async function startBroadcast(data: RequestData): Promise<object> {
  let streamId = null;
  try {
    const gameUid = data["gameUid"];
    const teamUid = data["teamUid"];
    const seasonUid = data["seasonUid"];
    if (
      gameUid === null ||
      gameUid === undefined ||
      teamUid === null ||
      teamUid === undefined ||
      seasonUid === null ||
      seasonUid === undefined
    ) {
      console.log("Invalid data ", data);
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Invalid input args"
      );
    }
    const dbMediaDoc: firestore.DocumentReference = db
      .collection("Media")
      .doc();

    // Create the broadcast.
    const response = await api({
      method: "post",
      url: c.CREATE_ANT_URL,
      data: {
        name: dbMediaDoc.id,
        expireDurationMS: 20000,
        description: "Live stream for " + dbMediaDoc.id,
        category: "game",
        listenerHookURL:
          "https://us-central1-basketballstats-8ed93.cloudfunctions.net/"
      }
    });
    streamId = response.data["streamId"];
    if (streamId === null || streamId === undefined) {
      console.log("Invalid response from ant ", response.data);
      throw new functions.https.HttpsError("aborted", "Bad response from ant");
    }

    // Success, send stuff back! and update the database.
    if (response.status === 200) {
      // Add the details into the database.
      await dbMediaDoc.set({
        description: "Live stream",
        gameUid: gameUid,
        seasonUid: seasonUid,
        teamUid: teamUid,
        type: "VideoStreaming",
        length: 0,
        streamId: streamId,
        uid: dbMediaDoc.id,
        expireDurationMS: 20000,
        uploadTime: firestore.FieldValue.serverTimestamp(),
        startAt: Date.now(),
        url: c.STREAM_URL_BASE + streamId + ".m3u8",
        rtmpUrl: c.RTMP_URL_BASE + streamId
      });

      //const data = JSON.parse(response.statusText);
      console.log(response.data);
      response.data["rtmpURL"] = c.RTMP_URL_BASE + streamId;
      response.data["streamURL"] = c.STREAM_URL_BASE + streamId + ".m3u8";
      return response.data;
    } else {
      throw new functions.https.HttpsError("aborted", "Not 200 status");
    }
  } catch (exception) {
    console.log("Error starting broadcast");
    console.log(exception);

    // Delete the broadcast if stuff goes wrong
    if (streamId !== null && streamId != undefined) {
      await axios.delete(c.BASE_BROADCAST_ANT_URL + streamId, {
        data: { streamId: streamId, name: streamId }
      });
    }
    throw new functions.https.HttpsError("internal", exception);
  }
}

///
/// Request to deal with incoming request to start a broadcast.
/// Talks to the media server to setup the system and then parses the results
/// back via the api to the frontend.
///
export default functions.https.onCall(
  (data, context): Promise<object> => {
    console.log("Doing stuff");
    console.log(data);
    if (context.auth === null || context.auth === undefined) {
      console.log("No auth ");
      throw new functions.https.HttpsError("unauthenticated", "No anything");
    }
    const tokenId = context.auth.token;
    if (tokenId === null || tokenId === undefined) {
      console.log("No auth token");
      throw new functions.https.HttpsError("unauthenticated", "No token");
    }

    return startBroadcast(data);
  }
);
