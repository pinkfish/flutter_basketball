import * as functions from "firebase-functions";
import axios from "axios";
import * as c from "../util/constants";

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
  streamId: string;
}

async function getBroadcast(data: RequestData): Promise<object> {
  try {
    const streamId = data["streamId"];
    if (streamId === null || streamId === undefined) {
      console.log("Invalid data ", data);
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Invalid input args"
      );
    }

    // Get the broadcast.
    const response = await api({
      method: "get",
      url: c.BASE_BROADCAST_ANT_URL + streamId,
      data: {}
    });
    const retStreamId = response.data["streamId"];
    if (retStreamId !== streamId) {
      console.log("Invalid response from ant ", response.data);
      throw new functions.https.HttpsError("aborted", "Bad response from ant");
    }

    // Success, send stuff back! and update the database.
    if (response.status === 200) {
      response.data["rtmpURL"] = c.RTMP_URL_BASE + streamId;
      response.data["streamURL"] = c.STREAM_URL_BASE + streamId + ".m3u8";
      return response.data;
    } else {
      throw new functions.https.HttpsError("aborted", "Not 200 status");
    }
  } catch (exception) {
    console.log("Error getting broadcast");
    console.log(exception);

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
    if (context.auth === null || context.auth === undefined) {
      console.log("No auth ");
      throw new functions.https.HttpsError("unauthenticated", "No anything");
    }
    const tokenId = context.auth.token;
    if (tokenId === null || tokenId === undefined) {
      console.log("No auth token");
      throw new functions.https.HttpsError("unauthenticated", "No token");
    }

    return getBroadcast(data);
  }
);
