import fetch from "node-fetch";
import log from "lambda-log";

/**
 * Moderates content
 * @param content object as specified in CleanSpeak API spec.https://www.inversoft.com/docs/cleanspeak/3.x/tech/apis/content
 * @param item id for persistent content
 * @returns Promise
 */

export const moderateContent = async (content, id) => {
  log.debug("moderateContent.api...");
  const host = process.env.API_URL;
  let url = `${host}/content/item/moderate`;
  if (id) url = `${host}/content/item/moderate/${id}`;
  const apiKey = process.env.API_KEY;
  const headers = {
    "Content-Type": "application/json",
    Authorization: apiKey
  };
  const params = {
    method: "POST",
    body: JSON.stringify(content),
    headers: headers
  };

  log.debug("moderateContent.request params...", params);
  const response = await fetch(url, params);
  const jsonResp = await response.json();
  log.debug("moderateContent.response...", jsonResp);
  if (response.status === 200) {
    const action = jsonResp.contentAction;
    if (action === "allow") {
      return;
    } else if (action === "replace") {
      //Send the replacement text
      return jsonResp.content.parts[0].replacement
        ? jsonResp.content.parts[0].replacement
        : "";
    } else {
      //todo Need to send proper message for "queuedforapproval"/"reject" action
      return "*****";
    }
  } else {
    throw handleErrorResponses(response.status, jsonResp);
  }
};

/**
 * Flag content
 * @param content object as specified in CleanSpeak API spec.https://www.inversoft.com/docs/cleanspeak/3.x/tech/apis/content
 * @param content id
 * @returns Promise
 */

export const flagContent = async (content, id) => {
  log.debug("flagContent.api...");
  const host = process.env.API_URL;
  let url = `${host}/content/item/flag/${id}`;
  const apiKey = process.env.API_KEY;
  const headers = {
    "Content-Type": "application/json",
    Authorization: apiKey
  };
  const params = {
    method: "POST",
    body: JSON.stringify(content),
    headers: headers
  };

  log.debug("flagContent.request params...", params);
  const response = await fetch(url, params);
  if (response.status === 200) return;
  else throw handleErrorResponses(response.status, await response.json());
};

const handleErrorResponses = (status, jsonResp) => {
  let err;
  if (status === 401) {
    err =
      "Moderation Error:You did not supply a valid Authorization header. The header was omitted or your API key was not valid.";
  } else if (status === 402) {
    err = "Moderation Error:Your license has expired.";
  } else if (status === 500) {
    err = "Moderation Error:CleanSpeak internal server error.";
  } else {
    err = jsonResp;
  }
  return err;
};
