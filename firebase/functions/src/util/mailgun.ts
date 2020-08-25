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
  return nodemailer.createTransport(mailTransport);
}

export function sendMail(
  mailOptions: nodemailer.SendMailOptions,
  emailClient: nodemailer.Transporter
): Promise<nodemailer.SentMessageInfo> {
  return new Promise<nodemailer.SentMessageInfo>((resolve, reject) => {
    emailClient.sendMail(mailOptions, (error, info) => {
      if (error !== null) {
        reject(error);
      } else {
        const previewUrl = nodemailer.getTestMessageUrl(info);
        if (previewUrl) {
          console.log("Preview URL: %s", previewUrl);
        }
        resolve(info);
      }
    });
  });
}
