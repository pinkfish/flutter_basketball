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
    console.log("exiting function " + object.contentType);
    return false;
  }

  const tempFilePath = path.join(os.tmpdir(), fileName);
  await bucket.file(filePath).download({ destination: tempFilePath });
  console.log("Video downloaded locally to", tempFilePath);

  await generateThumbnailFromPath(tempFilePath, tempFilePath).then(files => {
    return bucket.upload(tempFilePath, {
      destination: path.join(bucketDir, filePath + files[0])
    });
  });

  // 5. Cleanup remove the tmp/thumbs from the filesystem
  return fs.rmdir(bucketDir, { recursive: true });
});
