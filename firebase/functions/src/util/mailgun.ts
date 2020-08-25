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

// Let this be overrideable for tests.
export function getMailTransport(): nodemailer.Transporter {
  console.log("Getting mail transport mailgun");
  return nodemailer.createTransport(mailTransport);
}

export function sendMail(
  mailOptions: nodemailer.SendMailOptions,
  emailClient: nodemailer.Transporter
): Promise<nodemailer.SentMessageInfo> {
  return new Promise<nodemailer.SentMessageInfo>((resolve, reject) => {
    console.log("Sending " + mailOptions);
    emailClient.sendMail(mailOptions, (error, info) => {
      if (error !== null) {
        console.log("Error sending " + error);
        reject(error);
      } else {
        console.log("Preview URL: %s", nodemailer.getTestMessageUrl(info));
        resolve(info);
      }
    });
  });
}
