import * as sinon from "sinon";
import * as tssinon from "ts-sinon";
import * as os from "os";

import admin from "firebase-admin";
import firebaseFunctionsTest from "firebase-functions-test";
import { assert, expect } from "chai";
import { FfmpegCommand } from "fluent-ffmpeg";
import { Bucket, File } from "@google-cloud/storage";

import { internalOnWrite } from "../../../src/db/media/onWrite.f";
import onDelete from "../../../src/db/media/onDelete.f";
import { fakeDefaultExport } from "../../util/fakedefaultexport";
import * as media from "../../../src/util/media";

let test = firebaseFunctionsTest();

describe("Media Util Tests", () => {
  let adminInitStub: sinon.SinonStub;

  before(() => {
    test = firebaseFunctionsTest();
    adminInitStub = sinon.stub(admin, "initializeApp");
  });

  after(() => {
    test.cleanup();
    sinon.restore();
    adminInitStub.restore();
  });

  it("onWrite works", async () => {
    const myMap = new Map();
    myMap.set("fluent-ffmpeg", sinon.stub().returns("fake adding"));

    fakeDefaultExport("../../src/util/media", myMap);

    const beforeSnap: admin.firestore.DocumentSnapshot = test.firestore.makeDocumentSnapshot(
      { url: "http://35.186.244.82/bing.mp4", type: "VideoOnDemand" },
      "environments/dev/Media/1"
    );
    const afterSnap: admin.firestore.DocumentSnapshot = test.firestore.makeDocumentSnapshot(
      {
        url: "http://35.186.244.82/froggy.mp4",
        type: "VideoOnDemand",
        teamUid: "teams",
        seasonUid: "seasons",
        gameUid: "games",
        uid: "1"
      },
      "environments/dev/Media/1"
    );
    const afterRef = sinon.stub(afterSnap.ref, "update");
    afterRef.resolves({
      writeTime: new admin.firestore.Timestamp(42, 0),
      isEqual: (other: admin.firestore.WriteResult) => true
    });
    const ffmpeg = sinon.stub();
    const change = test.makeChange(beforeSnap, afterSnap);
    const ffmpegCommand = tssinon.stubInterface<FfmpegCommand>();
    ffmpeg.returns(ffmpegCommand);
    ffmpegCommand.on.returns(ffmpegCommand);

    // Setup the bucket returns
    const stubStorageFunc = sinon.stub(admin, "storage");
    const stubStorage = tssinon.stubInterface<admin.storage.Storage>();
    const stubBucket = tssinon.stubInterface<Bucket>();
    stubStorageFunc.get(() => {
      return () => stubStorage;
    });
    stubStorage.bucket.returns(stubBucket);
    stubBucket.upload.resolves(true);

    const fetchStub = sinon.stub(media, "fetchInto");

    fetchStub.callsFake((url, str) => {
      return new Promise((resolve, reject) => {
        resolve({});
      });
    });

    const thumbStub = sinon.stub(media, "generateThumbnailFromPath");
    thumbStub.callsFake((fname, ffmpeg) => {
      return new Promise((resolve, reject) => {
        resolve("frog");
      });
    });

    try {
      await internalOnWrite(change, ffmpeg);
      expect(ffmpeg.called).to.be.false;
      expect(afterRef.called).to.be.true;
      expect(stubStorage.bucket.calledWith("basketballstats-8ed93.appspot.com"))
        .to.be.true;
      const path = os.tmpdir() + "/1.mp4";
      assert.deepEqual(stubBucket.upload.firstCall.args, [
        "frog",
        {
          destination: "games/1_thumb.png",
          resumable: false,
          metadata: {
            gameUid: "games",
            mediaInfoUid: "1",
            teamUid: "teams",
            seasonUid: "seasons"
          }
        }
      ] as any);
      assert.deepEqual(stubBucket.upload.secondCall.args, [
        path,
        {
          destination: "games/1.mp4",
          resumable: false,
          metadata: {
            gameUid: "games",
            mediaInfoUid: "1",
            teamUid: "teams",
            seasonUid: "seasons"
          }
        }
      ] as any);

      expect(
        afterRef.calledWith(
          sinon.match({
            url: "gs://basketballstats-8ed93.appspot.com/bing.mp4",
            thumbnailUrl: "gs://basketballstats-8ed93.appspot.com/frog"
          })
        )
      );
    } catch (e) {
      console.log(e);
      expect(false).to.be.true;
    }
  }).timeout(5000);

  it("onDelete nothing to do", async () => {
    const stubStorageFunc = sinon.stub(admin, "storage");
    try {
      const stubStorage = tssinon.stubInterface<admin.storage.Storage>();
      stubStorageFunc.get(() => {
        return () => stubStorage;
      });
      const deleteSnap = test.firestore.makeDocumentSnapshot(
        { url: "http://rabbit.com", thumbnailUrl: "http://frog.com" },
        "environments/dev/Media/1"
      );
      const wrapped = test.wrap(onDelete);
      try {
        await wrapped(deleteSnap);
        expect(stubStorageFunc.called).to.be.false;
      } catch (e) {
        console.log(e);
        assert(false);
      }
    } finally {
      stubStorageFunc.restore();
    }
  });

  it("onDelete delete storage", async () => {
    const stubStorageFunc = sinon.stub(admin, "storage");
    try {
      const stubStorage = tssinon.stubInterface<admin.storage.Storage>();
      const stubBucket = tssinon.stubInterface<Bucket>();
      const stubFile = tssinon.stubInterface<File>();
      stubStorageFunc.get(() => {
        return () => stubStorage;
      });
      stubStorage.bucket.returns(stubBucket);
      stubBucket.file.returns(stubFile);
      const deleteSnap = test.firestore.makeDocumentSnapshot(
        { url: "gs://rabbit.com/path", thumbnailUrl: "gs://frog.com/path2" },
        "environments/dev/Media/1"
      );
      const wrapped = test.wrap(onDelete);
      await wrapped(deleteSnap);
      expect(stubStorage.bucket.calledWith("rabbit.com")).to.be.true;
      expect(stubStorage.bucket.calledWith("frog.com")).to.be.true;
      expect(stubBucket.file.calledWith("/path")).to.be.true;
      expect(stubBucket.file.calledWith("/path2")).to.be.true;
      expect(stubFile.delete.called).to.be.true;
    } finally {
      stubStorageFunc.restore();
    }
  });
});
