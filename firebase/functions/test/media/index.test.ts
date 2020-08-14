// Now we can require index.js and save the exports inside a namespace called myFunctions.
import { generateThumbnailFromPath } from "../../src/util/media";
import * as process from "process";
import * as fs from "fs";
import { assert, expect } from "chai";

describe("Media Util Tests", () => {
  it("makeThumbnail", async () => {
    console.log(process.cwd());
    const thumbFile = await generateThumbnailFromPath(
      "./test/media/data/rabbit-2020-05-04_07-11.mp4"
    );

    // Validate the file.
    const newFile = fs.readFileSync(thumbFile);
    const cmpFile = fs.readFileSync("./test/media/data/rabbit_1s_clip.png");

    // Validate they are the same.
    assert(Buffer.compare(newFile, cmpFile) === 0);
  });

  it("invalidFile", async () => {
    console.log(process.cwd());
    try {
      await generateThumbnailFromPath("./test/media/data/frog.mp4");
      assert(false);
    } catch (e) {
      expect(e.message).to.include("No such file or directory");
    }
  });
});
