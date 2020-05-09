import * as functions from "firebase-functions";
import admin from "firebase-admin";
import { Storage } from "@google-cloud/storage";
import nodeFetch from "node-fetch";
try {
  admin.initializeApp();
} catch (e) {
  console.log(e);
}

const storage = new Storage();

export default functions.firestore
  .document("Media/{mediaUid}")
  .onWrite(change => {
    // If it didn't exist or still exists then we update.
    const beforeUrl = change.before.exists ? change.before.data()?.url : "";
    const afterUrl = change.after.exists ? change.after.data()?.url : "";

    // Both finished so we don't do anything.
    if (afterUrl == beforeUrl && afterUrl.contains("35.186.244.82")) {
      return;
    }

    // Download from this url and upload to storage.
    const bucket = storage.bucket("media");

    // Create a WritableStream from the File
    const path = change.after.data()?.gameUid + "/" + change.after.data()?.uid;
    const file = bucket.file(path);
    const writeStream = file.createWriteStream();

    return nodeFetch("image.jpg").then(res => {
      return new Promise((resolve, reject) => {
        res.body.on("end", () => {
          resolve();
        });
        res.body.on("error", error => {
          reject(error);
        });
        res.body.pipe(writeStream);
      }).then(() => {
        return change.after.ref.update({
          url: "https://media.storage.googleapis.com/" + path,
          thumbnailUrl:
            "https://media.storage.googleapis.com/" + path + "_thumb.png"
        });
      });
    });
  });
