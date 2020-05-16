import admin from "firebase-admin";

export const BUCKET_NAME = "basketballstats-8ed93.appspot.com";
export const CREATE_ANT_URL =
  "http://34.70.40.166:5080/LiveApp/rest/v2/broadcasts/create";
export const BASE_BROADCAST_ANT_URL =
  "http://34.70.40.166:5080/LiveApp/rest/v2/broadcasts/";
export const RTMP_URL_BASE = "rtmp://34.70.40.166:1935/LiveApp/";
export const STREAM_URL_BASE = "http://34.70.40.166:5080/LiveApp/streams/";
export const CDN_URL_BASE = "35.186.244.82";

export const FIREBASE_APP_OPTIONS: admin.AppOptions = {
  storageBucket: BUCKET_NAME
};
