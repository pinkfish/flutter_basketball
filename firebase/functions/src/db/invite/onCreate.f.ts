import * as functions from "firebase-functions";
import * as nodemailer from "nodemailer";
import * as mailgun from "../../util/mailgun";
import * as handlebars from "handlebars";
import * as fs from "fs";
import * as c from "../../util/constants";
import admin from "firebase-admin";
import axios, { AxiosRequestConfig, AxiosResponse } from "axios";

try {
  admin.initializeApp(c.FIREBASE_APP_OPTIONS);
} catch (e) {
  if (e.errorInfo.code !== "app/duplicate-app") {
    console.log(e);
  }
}

const db = admin.firestore();

function getImageFromUrl(url: string): Promise<AxiosResponse<string>> {
  const getImageOptions: AxiosRequestConfig = {};
  const api = axios.create(getImageOptions);
  return api.get(url);
}

function getContentType(fullBody: AxiosResponse<unknown>): string {
  const contentType = fullBody.headers["content-type"];
  if (contentType === "application/octet-stream") {
    return "image/jpeg";
  }
  return contentType;
}

function mailToSender(
  inviteDoc: FirebaseFirestore.QueryDocumentSnapshot,
  sentByDoc: FirebaseFirestore.DocumentSnapshot<FirebaseFirestore.DocumentData>
): Promise<unknown> {
  const data = inviteDoc.data();
  const footerTxt = handlebars.compile(
    fs.readFileSync("db/templates/invites/footer.txt", "utf8")
  );
  const footerHtml = handlebars.compile(
    fs.readFileSync("db/templates/invites/footer.html", "utf8")
  );
  const attachments = [
    {
      filename: "apple-store-badge.png",
      path: "db/templates/invites/img/apple-store-badge.png",
      cid: "apple-store"
    },
    {
      filename: "google-store-badge.png",
      path: "db/templates/invites/img/google-play-badge.png",
      cid: "google-store"
    }
  ];

  const payloadTxt = handlebars.compile(
    fs.readFileSync("db/templates/invites/" + data.type + ".txt", "utf8")
  );
  const payloadHtml = handlebars.compile(
    fs.readFileSync("db/templates/invites/" + data.type + ".html", "utf8")
  );

  const sendByData = sentByDoc.data() ?? {
    name: "unknown"
  };

  const mailOptions: nodemailer.SendMailOptions = {
    from:
      '"' +
      sendByData.name +
      '" <' +
      data.sentByUid +
      "@st-email.teamsfuse.com>",
    to: data.email,
    attachments: attachments
  };
  const context = {
    sentBy: sendByData,
    invite: inviteDoc.data(),
    teaming: "",
    team: inviteDoc.data()
  };

  if (data.type === "InviteType.Team") {
    // Find the team details.
    return db
      .collection("Teams")
      .doc(data.teamUid)
      .get()
      .then(snapshot => {
        if (snapshot.exists) {
          const teamData = snapshot.data() ?? {
            photourl: null,
            name: "unknown"
          };

          let url;
          if (teamData.photourl) {
            url = teamData.photourl;
          } else {
            url = "db/templates/invites/img/defaultteam.jpg";
          }

          // Building Email message.
          context.teaming = "cid:teamurl";
          context.team = teamData;
          if (data.type === "InviteType.Team") {
            mailOptions.subject = "Invitation to join " + data.teamName;
          } else {
            mailOptions.subject =
              "Invitation to be an admin for " + teamData.name;
          }
          mailOptions.text = payloadTxt(context) + footerTxt(context);
          mailOptions.html = payloadHtml(context) + footerHtml(context);

          return Promise.all([mailOptions, getImageFromUrl(url)]);
        } else {
          return null;
        }
      })
      .then(dataInner => {
        if (dataInner === null) {
          return null;
        }
        const res = dataInner[1];
        const myMailOptions = dataInner[0];
        if (
          myMailOptions.attachments === null ||
          myMailOptions.attachments === undefined
        ) {
          console.log("Attachments are empty");
          return null;
        } else {
          myMailOptions.attachments.push({
            filename: "team.jpg",
            path: Buffer.from(res.data).toString("base64"),
            cid: "teamimg",
            contentType: getContentType(res),
            encoding: "base64"
          });

          return mailgun.sendMail(myMailOptions);
        }
      });
  }

  return new Promise(resolve => resolve(data));
}

//
// The main point for the onCreate call.
//
export default functions.firestore
  .document("Invites/{inviteUid}")
  .onCreate(snapshot => {
    const data = snapshot.data();

    if (data === null) {
      // Delete...
      return null;
    }

    // Already emailed about this invite.
    if (data.emailedInvite) {
      return null;
    }
    // lookup the person that sent the invite to get
    // their profile details.
    return db
      .collection("Users")
      .doc(data.sentbyUid)
      .get()
      .then(sentByDoc => {
        return mailToSender(snapshot, sentByDoc);
      })
      .then(() => {
        console.log("Sent email to " + data.email);
        return db
          .collection("Invites")
          .doc(snapshot.id)
          .update({ emailedInvite: true });
      })
      .catch(error =>
        console.error("There was an error while sending the email:", error)
      );
  });
