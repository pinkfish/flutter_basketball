import cors from "cors";
import * as functions from "firebase-functions";
import axios from "axios";
import admin from "firebase-admin";
import { firestore } from "firebase-admin";
try {
  admin.initializeApp();
} catch (e) {
  if (e.errorInfo.code !== "app/duplicate-app") {
    console.log(e);
  }
}

const db = admin.firestore();

const CREATE_ANT_URL = "http://34.70.40.166:5080/LiveApp/rest/broadcast/create";
const BASE_BROADCAST_ANT_URL =
  "http://34.70.40.166:5080/LiveApp/rest/broadcast/";
const RTMP_URL_BASE = "rtmp://34.70.40.166:5080/LiveApp/";
const STREAM_URL_BASE = "http://34.70.40.166:5080/LiveApp/streams/";

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

async function startBroadcast(
  req: functions.Request,
  res: functions.Response<string>,
  decoded: admin.auth.DecodedIdToken
): Promise<boolean> {
  let streamId = null;
  try {
    const data = req.body.data;
    if (data === null || data === undefined) {
      console.log("No json data");
      res.status(412).send("no json data");
      return false;
    }
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
      return false;
    }
    const dbMediaDoc: firestore.DocumentReference = db
      .collection("Media")
      .doc();

    // Create the broadcast.
    const response = await api({
      method: "post",
      url: CREATE_ANT_URL,
      data: {
        name: dbMediaDoc.id,
        expireDurationMS: 20000,
        desscription: "Live stream for " + dbMediaDoc.id,
        category: "game",
        listenerHookURL:
          "https://us-central1-basketballstats-8ed93.cloudfunctions.net/"
      }
    });
    streamId = response.data["streamId"];
    if (streamId === null || streamId === undefined) {
      console.log("Invalid response from ant ", response.data);
      res.status(412).send(response.data);
      return false;
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
        uid: dbMediaDoc.id,
        expireDurationMS: 20000,
        uploadTime: firestore.FieldValue.serverTimestamp(),
        startDate: Date.now(),
        url: STREAM_URL_BASE + streamId,
        rtmpUrl: RTMP_URL_BASE + streamId
      });

      //const data = JSON.parse(response.statusText);
      res.status(200).send(response.statusText);
    }
  } catch (exception) {
    console.log("Error starting broadcast");
    console.log(exception);
    res.status(412).send('{"error": "Error from media server"}');

    // Delete the broadcast if stuff goes wrong
    if (streamId !== null && streamId != undefined) {
      await axios.delete(BASE_BROADCAST_ANT_URL + streamId, {
        data: { streamId: streamId, name: streamId }
      });
    }
    return false;
  }
  return true;
}

///
/// Request to deal with incoming request to start a broadcast.
/// Talks to the media server to setup the system and then parses the results
/// back via the api to the frontend.
///
export default functions.https.onRequest((req, res) => {
  console.log("Doing stuff");
  console.log(req.body);
  console.log(req.params);
  const func = cors();
  return func(req, res, () => {
    const headerToken = req.get("Authorization");
    if (headerToken === null || headerToken === undefined) {
      console.log("missing auth token header");
      res.status(401).send('{"error": "no token"}');
      return;
    }
    const bits = headerToken.split("Bearer ");
    if (bits.length < 2) {
      console.log("Invalid auth token");
      res.status(401).send("invalid token");
      return;
    }
    const tokenId = bits[1];
    if (tokenId === null || tokenId === undefined) {
      console.log("No auth token");
      res.status(401).send("no token");
      return;
    }

    return admin
      .auth()
      .verifyIdToken(tokenId)
      .then(decoded => startBroadcast(req, res, decoded))
      .catch(err => res.status(401).send(err));
  });
});
