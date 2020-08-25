import urlBuilder from "build-url";
import * as functions from "firebase-functions";

import { AxiosInstance, AxiosResponse } from "axios";

interface ShortLinkResponse {
  shortLink: string;
}

export function makeDynamicLongLink(postId: string, teamName: string) {
  return urlBuilder("https://stats.whelksoft.com/invite/", {
    queryParams: {
      link: "https://stats.whelksoft.com/invite/" + postId,
      apn: "state.whelksoft.com",
      dfl: "https://stats.whelksoft.com",
      st: "BasketballStats - for stats and basketball",
      sd: "Invite to " + teamName,
      si:
        "https://stats.whelksoft.com/assets/assets/images/hands_and_trophy.png"
    }
  });
}

export async function getShortUrlDynamicLink(
  url: string,
  api: AxiosInstance
): Promise<string> {
  console.log("getShortUrlDynamicLink " + url);
  try {
    const data = (await api({
      method: "post",
      url: `https://firebasedynamiclinks.googleapis.com/v1/shortLinks?key=${
        functions.config().links.key
      }`,
      data: {
        longDynamicLink: url
      },
      responseType: "json"
    })) as AxiosResponse<ShortLinkResponse>;
    return data.data.shortLink;
  } catch (error) {
    throw error;
  }
}
