import * as functions from "firebase-functions";
import * as nodemailer from "nodemailer";
import mailgunTransport from "nodemailer-mailgun-transport";

// Configure options for mailgun.
const mailgunOptions: mailgunTransport.Options = {
  auth: {
    api_key: functions.config().mailgun.apikey, // eslint-disable-line
    domain: functions.config().mailgun.domain
  }
};

const mailTransport = mailgunTransport(mailgunOptions);

export function sendMail(
  mailOptions: nodemailer.SendMailOptions
): Promise<unknown> {
  const emailClient = nodemailer.createTransport(mailTransport);
  return emailClient.sendMail(mailOptions);
}
