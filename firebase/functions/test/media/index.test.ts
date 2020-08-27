// Now we can require index.js and save the exports inside a namespace called myFunctions.
import { generateThumbnailFromPath } from "../../src/util/media";
import * as fs from "fs";
import { assert, expect } from "chai";

describe("Media Util Tests", () => {
  it("makeThumbnail", async () => {
    const thumbFile = await generateThumbnailFromPath(
      "./test/media/data/rabbit-2020-05-04_07-11.mp4"
    );

    // Validate the file.
    const newFile = fs.readFileSync(thumbFile);
    const cmpFile = fs.readFileSync("./test/media/data/rabbit_1s_clip.png");

    // Validate they are the same.
    assert(Buffer.compare(newFile, cmpFile) === 0);
  }).timeout(10000);

  it("invalidFile", async () => {
    try {
      await generateThumbnailFromPath("./test/media/data/frog.mp4");
      assert(false);
    } catch (e) {
      expect(e.message).to.include("No such file or directory");
    }
  });
});
