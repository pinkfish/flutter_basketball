import * as functions from "firebase-functions";
import * as nodemailer from "nodemailer";
import * as mailgun from "../../util/mailgun";
import * as dl from "../../util/dynamiclink";
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
const getImageOptions: AxiosRequestConfig = {};
const api = axios.create(getImageOptions);

async function getImageFromUrl(url: string): Promise<AxiosResponse<string>> {
  if (url.startsWith("src")) {
    const data = fs.readFileSync(url, "utf8");
    return {
      data: data,
      status: 200,
      statusText: "OK",
      headers: {
        "content-type": "image/png"
      },
      config: getImageOptions
    };
  } else {
    return api.get(url);
  }
}

function getContentType(fullBody: AxiosResponse<unknown>): string {
  const contentType = fullBody.headers["content-type"];
  if (contentType === "application/octet-stream") {
    return "image/jpeg";
  }
  return contentType;
}

async function mailToSender(
  inviteData: FirebaseFirestore.DocumentData,
  sentByDoc: FirebaseFirestore.DocumentSnapshot<FirebaseFirestore.DocumentData>
): Promise<nodemailer.SentMessageInfo> {
  const footerTxt = handlebars.compile(
    fs.readFileSync("src/db/templates/invites/footer.txt", "utf8")
  );
  const footerHtml = handlebars.compile(
    fs.readFileSync("src/db/templates/invites/footer.html", "utf8")
  );
  const attachments = [
    {
      filename: "apple-store-badge.png",
      path: "src/db/templates/invites/img/apple-store-badge.png",
      cid: "apple-store"
    },
    {
      filename: "google-store-badge.png",
      path: "src/db/templates/invites/img/google-play-badge.png",
      cid: "google-store"
    }
  ];

  const payloadTxt = handlebars.compile(
    fs.readFileSync(
      "src/db/templates/invites/" + inviteData.type + ".txt",
      "utf8"
    )
  );
  const payloadHtml = handlebars.compile(
    fs.readFileSync(
      "src/db/templates/invites/" + inviteData.type + ".html",
      "utf8"
    )
  );

  const sendByData = sentByDoc.data() ?? {
    name: "unknown"
  };

  const mailOptions: nodemailer.SendMailOptions = {
    from:
      '"' +
      sendByData.name +
      '" <' +
      inviteData.sentByUid +
      "@st-email.teamsfuse.com>",
    to: inviteData.email,
    attachments: attachments
  };
  const context = {
    sentBy: sendByData,
    invite: inviteData,
    teamimg: "cid:teamimg",
    team: inviteData,
    dynamicLink: ""
  };
  try {
    const shortLink = await dl.getShortUrlDynamicLink(
      dl.makeDynamicLongLink(inviteData.uid, inviteData.teamName),
      api
    );
    context.dynamicLink = shortLink;
  } catch (error) {
    throw error;
  }

  if (inviteData.type === "InviteType.Team") {
    // Find the team details.
    const snapshot = await db
      .collection("Teams")
      .doc(inviteData.teamUid)
      .get();
    if (snapshot.exists) {
      const teamData = snapshot.data() ?? {
        photourl: null,
        name: "unknown"
      };

      let url;
      if (teamData.photourl) {
        url = teamData.photourl;
      } else {
        url = "src/db/templates/invites/img/defaultteam.jpg";
      }

      // Building Email message.
      context.team = teamData;
      if (inviteData.type === "InviteType.Team") {
        mailOptions.subject = "Invitation to join " + inviteData.teamName;
      } else {
        mailOptions.subject = "Invitation to be an admin for " + teamData.name;
      }
      mailOptions.text = payloadTxt(context) + footerTxt(context);
      mailOptions.html = payloadHtml(context) + footerHtml(context);

      const res = await getImageFromUrl(url);
      if (
        mailOptions.attachments === null ||
        mailOptions.attachments === undefined
      ) {
        console.log("Attachments are empty");
        return null;
      } else {
        mailOptions.attachments.push({
          filename: "team.jpg",
          content: Buffer.from(res.data).toString("base64"),
          cid: "teamimg",
          contentType: getContentType(res),
          encoding: "base64"
        });

        return mailgun.sendMail(mailOptions, mailgun.getMailTransport());
      }
    }
  }

  return new Promise(resolve => resolve(inviteData));
}

//
// The stuff to be done.
//
export async function doOnCreate(
  inviteUid: string,
  inviteData: FirebaseFirestore.DocumentData | undefined
): Promise<nodemailer.SentMessageInfo | undefined> {
  if (inviteData === null || inviteData === undefined) {
    // Delete...
    return undefined;
  }

  // Already emailed about this invite.
  if (inviteData.emailedInvite) {
    return undefined;
  }
  try {
    // lookup the person that sent the invite to get
    // their profile details.
    const sentByDoc = await db
      .collection("Users")
      .doc(inviteData.sentbyUid)
      .get();

    const info = await mailToSender(inviteData, sentByDoc);
    await db
      .collection("Invites")
      .doc(inviteUid)
      .update({ emailedInvite: true });
    return info;
  } catch (error) {
    throw error;
  }
}

//
// The main point for the onCreate call.
//
export default functions.firestore.document("Invites/{inviteUid}").onCreate(
  async (snapshot: FirebaseFirestore.DocumentSnapshot): Promise<unknown> => {
    return doOnCreate(snapshot.id, snapshot.data());
  }
);
