import { success, failure } from "./common/response-lib";
import * as cleanSpeakApi from "./common/cleanspeakapi-lib";
import log from "lambda-log";
import uuidv4 from "uuid/v4";

const rejectString = "*****";

export async function main(event, context, callback) {
  // Enable debug messages
  if (process.env.DEBUG_ENABLED) {
    log.config.debug = true;
  }
  try {
    log.debug("moderateText.main");
    const body = JSON.parse(event.body);
    const params = {
      text: body.text,
      ...event.queryStringParameters
    };
    log.config.meta.params = params;
    const moderatedText = await moderateText(params);
    log.debug(`moderateText.main response:`);
    log.debug(moderatedText);

    callback(null, success(buildResponse(body.text, moderatedText)));
  } catch (error) {
    log.error("moderateText.main:Error processing request");
    log.error(error);
    //Even on failure return a success so that comment is shown to the client.
    callback(null, success(error));
  }
}

const buildResponse = (originalText, moderatedText) => {
  let action = "allow";
  let text = originalText;
  if (originalText === rejectString) {
    action = "reject";
    text = moderatedText;
  } else if (moderatedText && originalText !== moderatedText) {
    action = "replace";
    text = moderatedText;
  }
  return {
    action,
    text
  };
};

/**
 * Handler Responsible for moderating the comments before it's posted on the comment channel.
 * @param params
 * @returns {Promise<void>}
 */
const moderateText = async params => {
  log.debug("moderateText.moderateText");
  try {
    // const msguuid = uuidv4();
    const modContent = await cleanSpeakApi.moderateContent(
      generateContentObj(params, params.text)
    );
    //return the replacement text
    if (modContent) return modContent;
    else return;
  } catch (error) {
    log.error("moderateText.moderateText:Error response:");
    log.error(error);
    //return a success on error so that the comments go through.
    //todo add this comment to the approval queue for post moderation
    return;
  }
};

const generateContentObj = (params, text, applicationId = null) => {
  //System UUID..
  let from = "fc156962-278f-44ec-b8d5-2e4afd6b055d";
  // if (params.Attributes) {
  //   const attr = JSON.parse(params.Attributes);
  //   from = attr.uuid || from;
  // }
  console.log("process.env.TEXT_APP_ID", process.env.TEXT_APP_ID);
  return {
    content: {
      applicationId: applicationId || process.env.TEXT_APP_ID,
      createInstant: new Date().getTime(),
      // location: params.ChannelSid,
      senderId: from,
      parts: [
        {
          content: text,
          name: "text",
          type: "text"
        }
      ]
    }
  };
};
