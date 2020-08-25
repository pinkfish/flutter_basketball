import * as sinon from "sinon";
import admin from "firebase-admin";
import firebaseFunctionsTest from "firebase-functions-test";
import { assert, expect } from "chai";
import * as dl from "../../../src/util/dynamiclink";
import * as nodemailer from "nodemailer";

const test = firebaseFunctionsTest({
  projectId: process.env.GCLOUD_PROJECT
});

test.mockConfig({
  mailgun: {
    apikey: "frog",
    domain: "frog.com"
  },
  links: {
    key: "rabbit"
  }
});

import onCreate from "../../../src/db/invite/onCreate.f";
import * as mailgun from "../../../src/util/mailgun";

describe("Invite Tests", () => {
  before(() => {});

  after(async () => {
    test.cleanup();
    sinon.restore();
    return;
  });

  it("onCreate works", async () => {
    const dynamicLinkStub = sinon.stub(dl, "getShortUrlDynamicLink");
    const getMailTransportOverride = sinon.stub(mailgun, "getMailTransport");
    dynamicLinkStub.callsFake((url, api) => {
      return new Promise((resolve, reject) => {
        resolve("bits");
      });
    });
    try {
      const account = await nodemailer.createTestAccount();

      // Create a SMTP transporter object
      getMailTransportOverride.returns(
        nodemailer.createTransport({
          host: account.smtp.host,
          port: account.smtp.port,
          secure: account.smtp.secure,
          auth: {
            user: account.user,
            pass: account.pass
          }
        })
      );

      const doc = test.firestore.makeDocumentSnapshot(
        {
          invite: "Team",
          sentByUid: "sentByFluff",
          teamUid: "team",
          teamName: "teamName",
          email: "frog@example.com",
          uid: "1"
        },
        "environments/dev/Invites/1"
      );

      // Setup some data to be queried first.
      await admin
        .firestore()
        .collection("Users")
        .doc("sentByFluff")
        .set({
          name: "Fluff",
          email: "fluff@example.com"
        });
      await admin
        .firestore()
        .collection("Teams")
        .doc("team")
        .set({
          name: "Lookup TeamName",
          photourl: null
        });
      await admin
        .firestore()
        .collection("Invites")
        .doc("1")
        .set(doc.data());

      try {
        await test.wrap(onCreate)(doc, {
          auth: {
            uid: "me"
          },
          authType: "USER"
        });
        expect(getMailTransportOverride.calledOnce).to.be.true;
        const data = await admin
          .firestore()
          .collection("Invites")
          .doc("1")
          .get();
        expect(data).to.not.be.null;
        if (data !== null && data !== undefined) {
          assert(data.exists);
          const myData = data.data();
          expect(myData).to.not.be.null;
          if (myData !== undefined && myData !== null) {
            expect(myData.emailedInvite).to.be.true;
          }
        }
      } catch (e) {
        console.log(e);
        console.log(e.stack);
        throw e;
      }
      return;
    } catch (e) {
      throw e;
    } finally {
      dynamicLinkStub.restore();
      getMailTransportOverride.restore();
    }
  }).timeout(10000);
});
