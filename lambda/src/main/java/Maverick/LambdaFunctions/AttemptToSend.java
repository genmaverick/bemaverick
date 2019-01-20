package Maverick.LambdaFunctions;

import Maverick.ExternalHelper;
import Maverick.LeanplumModels.LeanplumMessage;
import Maverick.LeanplumModels.LeanplumRequest;
import Maverick.MaverickModels.*;
import Maverick.LeanplumModels.GenericResponseBody;
import com.amazonaws.serverless.proxy.model.AwsProxyRequest;
import com.amazonaws.serverless.proxy.model.AwsProxyResponse;
import com.amazonaws.services.dynamodbv2.AmazonDynamoDB;
import com.amazonaws.services.dynamodbv2.AmazonDynamoDBClientBuilder;
import com.amazonaws.services.dynamodbv2.document.*;
import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.util.Iterator;


public class AttemptToSend implements RequestHandler<AwsProxyRequest, AwsProxyResponse> {

    public enum NotificationType {
        FOLLOWS, BADGED, FAVORITED, MODERATED
    }

    public AwsProxyResponse handleRequest(AwsProxyRequest request, Context context) {

        try {

            System.out.println("Starting: AttemptToSend");
            if (System.getenv("devMode") != null) {

                ExternalHelper.setDevMode(Boolean.parseBoolean(System.getenv("devMode")));

            }

            return doWork(request);

        } catch (Exception e) {

            System.out.println("Failed Somewhere: " + e.getMessage());

        } finally {

            return new AwsProxyResponse(200);

        }
    }




    private AwsProxyResponse doWork(AwsProxyRequest request) {


        String pushMessageId_priority = System.getenv("pushMessageId_priority");
        String pushMessageId_follow = System.getenv("pushMessageId_follow");
        String pushMessageId_post = System.getenv("pushMessageId_posts");
//        String appInboxMessageId = System.getenv("appInboxMessageId");
        String appInboxMessageId_priority = System.getenv("appInboxMessageId_priority");

        LeanplumRequest lpRequest = new LeanplumRequest();

        try {

            lpRequest = ExternalHelper.getInstance().getMapper().readValue(request.getBody(), LeanplumRequest.class);

        } catch (IOException e) {

            e.printStackTrace();
            return new AwsProxyResponse(203);

        }

        if (lpRequest.getDevMode() != null) {

            System.out.println("DevMode Override Set: " + Boolean.parseBoolean(lpRequest.getDevMode()));
            ExternalHelper.setDevMode(Boolean.parseBoolean(lpRequest.getDevMode()));

        }

        appInboxMessageId_priority = System.getenv("appInboxMessageId_priority");


        ExternalHelper.getInstance().printObject("Request" , lpRequest);

        NotificationType notificationType = NotificationType.FOLLOWS;
        String notificationId = "empty";
        if (lpRequest.getRequestType() != null) {

            if (lpRequest.getRequestType().equals("follows")) {

                notificationType = NotificationType.FOLLOWS;
                notificationId = lpRequest.getSourceUserId() + lpRequest.getRequestType() + lpRequest.getTargetUserId();

            } else if (lpRequest.getRequestType().equals("badged")) {

                notificationType = NotificationType.BADGED;
                notificationId = lpRequest.getSourceUserId() + lpRequest.getRequestType() + lpRequest.getSubjectId();

            } else if (lpRequest.getRequestType().equals("favorited")) {

                notificationType = NotificationType.FAVORITED;
                notificationId = lpRequest.getSourceUserId() + lpRequest.getRequestType() + lpRequest.getSubjectId();

            }else if (lpRequest.getRequestType().equals("moderated")) {

                notificationType = NotificationType.MODERATED;
                notificationId = lpRequest.getSourceUserId() + lpRequest.getRequestType() + lpRequest.getSubjectId()+ "_" + System.currentTimeMillis();

            }

        } else {

            return new AwsProxyResponse(501);

        }

        System.out.println("checking notificationId: " + notificationId);
        AmazonDynamoDB ddb = AmazonDynamoDBClientBuilder.defaultClient();
        DynamoDB dynamoDB = new DynamoDB(ddb);


        Table table = dynamoDB.getTable(ExternalHelper.getTableName());

        Item item = table.getItem("id", notificationId);
        GenericResponseBody shouldSendResponse = new GenericResponseBody();

        User user = null;
        String copyMessage = null;
        if (item == null) {

            user = ExternalHelper.getInstance().getUserObject(lpRequest.getSourceUserId());

        } else {

            System.out.println("item != null");

        }


        //dont send if cant find user or the user is the same as the target
        if (user == null) {
            ddb.shutdown();
            try {

                return new AwsProxyResponse(200, null, ExternalHelper.getInstance().getMapper().writeValueAsString(shouldSendResponse));

            } catch (JsonProcessingException e) {
                System.out.println("error");
                e.printStackTrace();

                return new AwsProxyResponse(501);
            }

        } else {

            LeanplumMessage message = new LeanplumMessage();
            message.setUserId(lpRequest.getTargetUserId());
            LeanplumMessage.LPValues values = new LeanplumMessage.LPValues();

            if (lpRequest.getCelebration().isValid()) {

                values.setCelebrationCopy1(lpRequest.getCelebration().getCopy1());
                String copy2 = String.format(lpRequest.getCelebration().getCopy2(), user.getUsername());
                values.setCelebrationCopy2(copy2);
                values.setCelebrationColor(lpRequest.getCelebration().getColor_rrggbbaa());

                if (lpRequest.getCelebration().getImage() == null) {

                    values.setCelebrationImage(user.getAvatarUrl());

                } else {

                    values.setCelebrationImage(lpRequest.getCelebration().getImage());

                }
            }

            values.setTargetDeepLinkUrl(lpRequest.getTargetDeepLinkUrl());
            values.setSourceDeepLinkUrl(lpRequest.getSourceDeepLinkUrl());


            switch (notificationType) {
                default:
                case FOLLOWS:
                    message.setMessageId(pushMessageId_priority);
                    values.setTargetImageUrl(user.getAvatarUrl());
                    copyMessage = String.format(lpRequest.getNotificationCopy(), user.getUsername());
                    break;

                case BADGED:
                case FAVORITED:
                case MODERATED:

                    message.setMessageId(pushMessageId_post);

                    if ( notificationType == NotificationType.FAVORITED || notificationType == NotificationType.MODERATED ) {

                        message.setMessageId(pushMessageId_priority);

                    }

                    message.setUserId(lpRequest.getTargetUserId());
                    System.out.println("BADGED processing lpRequest.getSubjectId():" + lpRequest.getSubjectId());
                    Response responseObject = ExternalHelper.getInstance().getResponseObject(lpRequest.getSubjectId());
                    message.setUserId(responseObject.getUserId());
                    values.setTargetImageUrl(responseObject.getImageURL());
                    values.setSourceImageUrl(user.getAvatarUrl());

                    if (responseObject.getChallengeTitle() == null && lpRequest.getNotificationCopyNoChallenge() != null) {

                        copyMessage = String.format(lpRequest.getNotificationCopyNoChallenge(), user.getUsername());

                    } else {

                        copyMessage = String.format(lpRequest.getNotificationCopy(), user.getUsername(), responseObject.getChallengeTitle());

                    }

                    break;

            }


            if (lpRequest.getSourceUserId() != null && lpRequest.getTargetUserId() != null && lpRequest.getSourceUserId().equals(message.getUserId())) {

                System.out.println("Wont send to self");
                return new AwsProxyResponse(203);
            }



            Iterator<Item> iter = ExternalHelper.getInstance().getUnreadNotifications(table, message.getUserId()).iterator();

            int i = 1;
            while (iter.hasNext()) {
                iter.next();
                i++;

            }
            values.setBadgeNumber(i);

            values.setImage_url(trimImageUrl(values.getTargetImageUrl()));

            values.setNotificationCopy(copyMessage);

            message.setValues(values);


            item = new Item().withPrimaryKey("id", notificationId)
                    .withLong("timeStamp", System.currentTimeMillis())
                    .withString("subjectId", lpRequest.getSubjectId())
                    .withString("subjectType", lpRequest.getSubjectType())
                    .withString("requestType", lpRequest.getRequestType())
                    .withString("sourceUserId", lpRequest.getSourceUserId())
                    .withString("notificationCopy", copyMessage)
                    .withString("targetUserId", message.getUserId())
                    .withString("targetImageUrl", message.getValues().getTargetImageUrl())
                    .withString("targetDeepLinkUrl", message.getValues().getTargetDeepLinkUrl())
                    .withString("sourceImageUrl", message.getValues().getSourceImageUrl())
                    .withString("sourceDeepLinkUrl", message.getValues().getSourceDeepLinkUrl())
                    .withBoolean("unread", true)
            ;
            table.putItem(item);

            ddb.shutdown();


            ExternalHelper.getInstance().sendLeanplumMessage(message);
            message.setMessageId(appInboxMessageId_priority);
            if (ExternalHelper.getInstance().sendLeanplumMessage(message)) {
                try {

                    return new AwsProxyResponse(200, null, ExternalHelper.getInstance().getMapper().writeValueAsString(message));

                } catch (JsonProcessingException e) {
                    e.printStackTrace();


                    return new AwsProxyResponse(203);

                }

            } else {


                return new AwsProxyResponse(203);
            }


        }

    }

    private String trimImageUrl(String url) {
        String returnValue = url.replaceFirst("https://","");
        return  returnValue.replaceFirst("http://","");
    }


    public static void main(String[] args) {
        // Prints "Hello, World" to the terminal window.
        System.out.println("Hello, World");

        ExternalHelper.getInstance().getUserObject("40");

        ExternalHelper.getInstance().getResponseObject("2");
    }


}