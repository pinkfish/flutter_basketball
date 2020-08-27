import {
  FfmpegCommand,
  FfmpegCommandOptions,
  ScreenshotsConfig,
  setFfmpegPath,
  setFfprobePath
} from "fluent-ffmpeg";
import Ffmpeg from "fluent-ffmpeg";
import pathToFfmpeg from "ffmpeg-static";
import * as os from "os";
import * as pathToFfprobe from "ffprobe-static";
import nodeFetch from "node-fetch";
import { WriteStream } from "fs";

import "node-fetch";

const THUMB_MAX_WIDTH = "200x200";

export async function fetchInto(
  url: string,
  writeStream: WriteStream
): Promise<unknown> {
  const fetchResult = await nodeFetch(url);

  return new Promise((resolve, reject) => {
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
}

function getFfmpegInstance(source: ReadableStream<Uint8Array>): FfmpegCommand {
  const options: FfmpegCommandOptions = {};
  return new FfmpegCommand(source as any, options); // eslint-disable-line  @typescript-eslint/no-explicit-any
}

export function generateThumbnailFromUrl(
  url: string,
  outputFolder: string
): Promise<string[]> {
  const settings: ScreenshotsConfig = {
    folder: outputFolder,
    count: 1,
    size: THUMB_MAX_WIDTH,
    filename: "%b-thumbnail-%r-%000i"
  };

  let filenameArray: string[] = [];

  return fetch(url).then(res => {
    return new Promise((resolve, reject) => {
      function complete(): void {
        resolve(filenameArray);
      }

      function filenames(fns: string[]): void {
        filenameArray = fns;
      }

      if (res.body !== null) {
        const ffmpeg = getFfmpegInstance(res.body);
        ffmpeg
          .on("filenames", filenames)
          .on("end", complete)
          .on("error", reject)
          .screenshots(settings);
      } else {
        reject("No data in the body");
      }
    });
  });
}

//
// Generates a thumbnail from the specified path into the folder
//
export function generateThumbnailFromPath(
  path: string,
  testFfmpeg?: (n: string) => FfmpegCommand
): Promise<string> {
  const settings: ScreenshotsConfig = {
    folder: os.tmpdir(),
    count: 1,
    size: THUMB_MAX_WIDTH,
    timemarks: [1], // 1 second in
    filename: "%ibits.png"
  };

  let filenameArray: string[] = [];

  setFfmpegPath(pathToFfmpeg);
  setFfprobePath(pathToFfprobe.path);

  const ffmpeg =
    testFfmpeg !== null && testFfmpeg !== undefined
      ? testFfmpeg(path)
      : Ffmpeg(path);
  ffmpeg.on("start", () => {
    //console.log("Ffmpeg command line: " + commandLine);
  });

  return new Promise<string[]>((resolve, reject) => {
    function complete(): void {
      resolve(filenameArray);
    }

    function filenames(fns: string[]): void {
      filenameArray = fns;
    }

    ffmpeg
      .on("filenames", filenames)
      .on("end", complete)
      .on("error", reject)
      .screenshots(settings);
  }).then((fnames: string[]) => {
    return Promise.resolve(settings.folder + "/" + fnames[0]);
  });
}
