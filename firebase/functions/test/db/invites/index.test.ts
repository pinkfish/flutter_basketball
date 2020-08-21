/*
import * as sinon from "sinon";
import admin from "firebase-admin";
//import * as chai from "chai";
import firebaseFunctionsTest from "firebase-functions-test";
import { assert } from "chai";

let test = firebaseFunctionsTest();

const adminInitStub = sinon.stub(admin, "initializeApp");
const dbStub = sinon.stub(admin, "firestore");

test.mockConfig({
    mailgun: {
      apikey: "frog",
      domain: "frog.com"
    }
  });


import onCreate from "../../../src/db/invite/onCreate.f";

describe("Media Util Tests", () => {
  before(() => {
    test = firebaseFunctionsTest();
  });

  after(() => {
    test.cleanup();
    sinon.restore();
  });

  it("onCreate works", async () => {
    const doc = test.firestore.makeDocumentSnapshot(
      { type: "InviteType.Team", sentbyUid: "sentByFluff"
    },
      "environments/dev/Invites/1"
    );

    const collectionStub = sinon.stub();

    dbStub.returns(
collectionStub
    );

    try {
      await onCreate(doc);
    } catch (e) {
      console.log(e);
      assert(false);
    }
  });
});
*/
