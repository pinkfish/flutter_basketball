import { Storage } from "@google-cloud/storage";
const gcs = new Storage();

import * as functions from "firebase-functions";
import { generateThumbnailFromPath } from "../util/media";
import * as path from "path";
import * as os from "os";
import { promises as fs } from "fs";

export default functions.storage.object().onFinalize(async object => {
  const bucket = gcs.bucket(object.bucket);
  const filePath = object.name;
  if (filePath === null || filePath === undefined) {
    console.log("exiting function filePath null");
    return false;
  }
  const fileName = filePath.split("/").pop();
  if (fileName === null || fileName == undefined) {
    console.log("exiting function fileName null");
    return false;
  }
  const bucketDir = path.dirname(filePath);
  if (object.contentType === null || object.contentType === undefined) {
    console.log("exiting function contentType null");
    return false;
  }

  if (fileName.includes("thumb") || !object.contentType.includes("video")) {
    console.log("not a video or already a thumbnail " + object.contentType);
    return false;
  }

  const thumbnailPath = filePath.replace(".mp4", "_thumb.png");

  const tempFilePath = path.join(os.tmpdir(), fileName);
  if (await bucket.file(thumbnailPath).exists()) {
    console.log("Thumb already exists");
    return false;
  }
  await bucket.file(filePath).download({ destination: tempFilePath });
  console.log("Video downloaded locally to", tempFilePath);

  try {
    const files = await generateThumbnailFromPath(tempFilePath);
    console.log("Generatedtheumbail ", files[0]);
    await bucket.upload(tempFilePath, {
      destination: path.join(bucketDir, filePath + files[0])
    });
    console.log("Deleting directory ", bucketDir);
    // 5. Cleanup remove the tmp/thumbs from the filesystem
    await fs.rmdir(bucketDir, { recursive: true });
    return true;
  } catch (error) {
    console.log("Errors in stuff ", error);
    return false;
  }
});
