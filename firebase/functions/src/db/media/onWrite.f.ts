import * as functions from "firebase-functions";
import admin from "firebase-admin";
import nodeFetch from "node-fetch";
import * as os from "os";
import * as fs from "fs";
import * as c from "../../util/constants";
import { generateThumbnailFromPath } from "../../util/media";
import { setFfmpegPath, FfmpegCommand } from "fluent-ffmpeg";
import pathToFfmpeg from "ffmpeg-static";

try {
  admin.initializeApp(c.FIREBASE_APP_OPTIONS);
} catch (e) {
  if (e.errorInfo.code !== "app/duplicate-app") {
    console.log(e);
  }
}

type FfmpegCallback = (n: string) => FfmpegCommand;

export async function internalOnWrite(
  change: functions.Change<functions.firestore.DocumentSnapshot>,
  testFfmpeg?: FfmpegCallback
) {
  // If it didn't exist or still exists then we update.
  const afterUrl = change.after.exists ? change.after.data()?.url : "";
  // Both finished so we don't do anything.
  if (
    //afterUrl == beforeUrl ||
    !afterUrl.includes(c.CDN_URL_BASE) ||
    change.after.data()?.type !== "VideoOnDemand"
  ) {
    console.log(
      "Not the right url or type",
      afterUrl,
      " ",
      change.after.data()?.type
    );
    return false;
  }
  console.log("bing", testFfmpeg);

  // Download from this url and upload to storage.
  const bucket = admin.storage().bucket(c.BUCKET_NAME);

  // Create a WritableStream from the File
  //const path =
  //  change.after.data()?.gameUid + "/" + change.after.data()?.uid + ".mp4";
  const path =
    change.after.data()?.gameUid + "/" + change.after.data()?.uid + ".mp4";
  const thumbPath =
    change.after.data()?.gameUid +
    "/" +
    change.after.data()?.uid +
    "_thumb.png";
  //const file = bucket.file(path + ".mp4");
  const tempFileName = os.tmpdir() + "/" + change.after.data()?.uid + ".mp4";
  const writeStream = fs.createWriteStream(tempFileName);
  //const writeStream = file.createWriteStream();

  try {
    console.log("Fetch ", afterUrl);
    const fetchResult = await nodeFetch(afterUrl);
    await new Promise((resolve, reject) => {
      console.log("Frogs");
      fetchResult.body.on("end", () => {
        console.log("end");
        resolve();
      });
      fetchResult.body.on("error", error => {
        console.log("Error ", error);
        writeStream.close();
        reject(error);
      });
      fetchResult.body.pipe(writeStream);
    });
    writeStream.close();
    if (fs.existsSync(tempFileName)) {
      //console.log("exists", fs.fstatSync(tempFileName));
    } else {
      console.log("does not exists", tempFileName);
    }
    console.log(pathToFfmpeg);
    console.log(fs.existsSync(pathToFfmpeg));
    setFfmpegPath(pathToFfmpeg);
    const thumbFile = await generateThumbnailFromPath(tempFileName, testFfmpeg);

    // Upload the thumbnail first so the storage bit doesn't trigger.
    await bucket.upload(thumbFile, {
      destination: thumbPath,
      resumable: false,
      metadata: {
        gameUid: change.after.data()?.gameUid,
        mediaInfoUid: change.after.id,
        teamUid: change.after.data()?.teamUid,
        seasonUid: change.after.data()?.seasonUid
      }
    });

    // Upload the main file.
    const uploadFile = await bucket.upload(tempFileName, {
      destination: path,
      resumable: false,
      metadata: {
        gameUid: change.after.data()?.gameUid,
        mediaInfoUid: change.after.id,
        teamUid: change.after.data()?.teamUid,
        seasonUid: change.after.data()?.seasonUid
      }
    });
    console.log("Upload resonse ", uploadFile);

    const updateStuff = await change.after.ref.update({
      url: "gs://" + c.BUCKET_NAME + "/" + path,
      thumbnailUrl: "gs://" + c.BUCKET_NAME + "/" + thumbPath
    });
    console.log("Upload resonse ", updateStuff);
    return true;
  } catch (error) {
    console.log("Error in this process ", error);
    return false;
  }
}

export default functions.firestore
  .document("Media/{mediaUid}")
  .onWrite(async change => {
    return internalOnWrite(change);
  });
