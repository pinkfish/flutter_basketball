// Now we can require index.js and save the exports inside a namespace called myFunctions.
import { assert, expect } from "chai";
import * as nodemailer from "nodemailer";
import firebaseFunctionsTest from "firebase-functions-test";

let test = firebaseFunctionsTest();

test.mockConfig({
  mailgun: {
    apikey: "frog",
    domain: "frog.com"
  }
});

import { sendMail, getMailTransport } from "../../src/util/mailgun";

describe("Mailgun Util Tests", () => {
  before(() => {
    test = firebaseFunctionsTest();
  });

  after(() => {
    test.cleanup();
  });

  it("sendEmail", async () => {
    const mailOptions: nodemailer.SendMailOptions = {
      from: "frog@frog.com",
      to: "frog@example.com",
      subject: "This is a test"
    };
    try {
      await sendMail(mailOptions, getMailTransport());
      assert(false);
    } catch (e) {
      expect(e.message).to.include("Forbidden");
    }
  });
});
