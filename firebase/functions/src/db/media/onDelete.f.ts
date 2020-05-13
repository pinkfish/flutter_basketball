import * as functions from "firebase-functions";
import admin from "firebase-admin";
import { Storage } from "@google-cloud/storage";
import axios from "axios";
try {
  admin.initializeApp();
} catch (e) {
  if (e.errorInfo.code !== "app/duplicate-app") {
    console.log(e);
  }
}

const BASE_BROADCAST_ANT_URL =
  "http://34.70.40.166:5080/LiveApp/rest/broadcast/";

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

const storage = new Storage();

export default functions.firestore
  .document("Media/{mediaUid}")
  .onDelete(doc => {
    // If it didn't exist or still exists then we update.
    if (doc.data()?.type === "VideoStreaming") {
      return api({
        method: "post",
        url: BASE_BROADCAST_ANT_URL + doc.data()?.streamId,
        data: {
          name: doc.id
        }
      });
    }

    if (doc.data()?.type === "VideoOnDemand") {
      // Download from this url and upload to storage.
      const bucket = storage.bucket("media");
      const path = doc.data()?.gameUid + "/" + doc.data()?.uid;
      const file = bucket.file(path);
      return file.delete();
    }
    return false;
  });
