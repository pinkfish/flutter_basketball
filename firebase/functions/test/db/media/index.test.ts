import * as sinon from "sinon";
import * as tssinon from "ts-sinon";
import admin from "firebase-admin";
//import * as chai from "chai";
import firebaseFunctionsTest from "firebase-functions-test";
import { assert } from "chai";
import nodeFetch from "node-fetch";
import proxyquire from "proxyquire";
import { FfmpegCommand } from "fluent-ffmpeg";

import { internalOnWrite } from "../../../src/db/media/onWrite.f";
import onDelete from "../../../src/db/media/onDelete.f";

let test = firebaseFunctionsTest();

function fakeDefaultExport(
  moduleRelativePath: string,
  stubs: Map<string, sinon.SinonStub>
) {
  if (require.cache[require.resolve(moduleRelativePath)]) {
    delete require.cache[require.resolve(moduleRelativePath)];
  }
  for (let [key, value] of stubs) {
    const mod = tssinon.stubInterface<NodeModule>();
    mod.exports.returns(value);
    require.cache[require.resolve(key)] = mod;
  }

  return require(moduleRelativePath);
}

describe("Media Util Tests", () => {
  let adminInitStub: sinon.SinonStub;
  let fetchStub: sinon.SinonStub;

  before(() => {
    test = firebaseFunctionsTest();
    adminInitStub = sinon.stub(admin, "initializeApp");
    fetchStub = proxyquire("../../util/media");
  });

  after(() => {
    test.cleanup();
    sinon.restore();
    adminInitStub.restore();
  });

  it("onWrite works", async () => {
    const myMap = new Map();
    myMap.set("fluent-ffmpeg", sinon.stub().returns("fake adding"));

    fakeDefaultExport("../../../src/util/media", myMap);

    const beforeSnap = test.firestore.makeDocumentSnapshot(
      { url: "http://35.186.244.82/bing.mp4" },
      "environments/dev/Media/1"
    );
    const afterSnap = test.firestore.makeDocumentSnapshot(
      { url: "http://35.186.244.82/froggy.mp4" },
      "environments/dev/Media/1"
    );
    const ffmpeg = sinon.stub();
    const change = test.makeChange(beforeSnap, afterSnap);
    const ffmpegCommand = tssinon.stubInterface<FfmpegCommand>();
    ffmpeg.returns(ffmpegCommand);

    try {
      await internalOnWrite(change, ffmpeg);
    } catch (e) {
      console.log(e);
      assert(false);
    }
  });

  it("onDelete nothing to do", async () => {
    const stubStorage = sinon.stub(admin, "storage");
    // const myStub = tssinon.stub(admin, "storage");
    // myStub.returns(stubStorage);
    const deleteSnap = test.firestore.makeDocumentSnapshot(
      { url: "http://rabbit.com", thumbnailUrl: "http://frog.com" },
      "environments/dev/Media/1"
    );
    const wrapped = test.wrap(onDelete);
    try {
      await wrapped(deleteSnap);
    } catch (e) {
      console.log(e);
      assert(false);
    }
    stubStorage.restore();
  });
});
