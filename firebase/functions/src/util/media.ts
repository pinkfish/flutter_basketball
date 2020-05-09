//import { ChildProcess, spawn } from 'child_process';
//import * as os from 'os';
//import * as path from 'path';
//import * as fs from 'fs';
//import * as http from 'http';
import {
  FfmpegCommand,
  FfmpegCommandOptions,
  ScreenshotsConfig
} from "fluent-ffmpeg";
import "node-fetch";

const THUMB_MAX_WIDTH = "100";

function getFfmpegInstance(source: ReadableStream<Uint8Array>): FfmpegCommand {
  const options: FfmpegCommandOptions = {};
  return new FfmpegCommand(source as any, options);
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

export function generateThumbnailFromPath(
  path: string,
  outputFolder: string
): Promise<string[]> {
  const settings: ScreenshotsConfig = {
    folder: outputFolder,
    count: 1,
    size: THUMB_MAX_WIDTH,
    filename: "_thumb.png"
  };

  let filenameArray: string[] = [];

  const ffmpeg = new FfmpegCommand(path);

  return new Promise((resolve, reject) => {
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
  });
}
