import * as functions from "firebase-functions";
import * as c from "../../util/constants";
import admin from "firebase-admin";
import axios from "axios";
try {
  admin.initializeApp(c.FIREBASE_APP_OPTIONS);
} catch (e) {
  if (e.errorInfo.code !== "app/duplicate-app") {
    console.log(e);
  }
}

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

async function deleteFile(fname: string): Promise<unknown> {
  if (fname.startsWith("gs://")) {
    const myUrl = new URL(fname);
    const bucket = admin.storage().bucket(myUrl.hostname);
    const myFile = bucket.file(myUrl.pathname);
    try {
      await myFile.delete();
    } catch (e) {
      console.log("Failed to delete ", e);
    }
  }
  return;
}

export default functions.firestore.document("Media/{mediaUid}").onDelete(
  async (doc: FirebaseFirestore.QueryDocumentSnapshot): Promise<unknown> => {
    if (doc.data()?.url !== null) {
      await deleteFile(doc.data()?.url);
    }
    if (doc.data()?.thumbnailUrl.startsWith("gs://")) {
      await deleteFile(doc.data()?.thumbnailUrl);
    }
    // If it didn't exist or still exists then we update.
    if (doc.data()?.type === "VideoStreaming") {
      return api({
        method: "post",
        url: c.BASE_BROADCAST_ANT_URL + doc.data()?.streamId,
        data: {
          name: doc.id
        }
      });
    }

    return false;
  }
);
