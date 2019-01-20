package Maverick.LambdaFunctions;

import Maverick.ExternalHelper;
import Maverick.LeanplumModels.GenericResponseBody;
import Maverick.LeanplumModels.LeanplumMessage;
import Maverick.LeanplumModels.LeanplumMultiMessage;
import Maverick.LeanplumModels.LeanplumRequest;
import Maverick.MaverickModels.Challenge;
import Maverick.MaverickModels.Response;
import Maverick.MaverickModels.User;
import com.amazonaws.serverless.proxy.model.AwsProxyRequest;
import com.amazonaws.serverless.proxy.model.AwsProxyResponse;
import com.amazonaws.services.dynamodbv2.AmazonDynamoDB;
import com.amazonaws.services.dynamodbv2.AmazonDynamoDBClientBuilder;
import com.amazonaws.services.dynamodbv2.document.DynamoDB;
import com.amazonaws.services.dynamodbv2.document.Item;
import com.amazonaws.services.dynamodbv2.document.Table;
import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.KinesisEvent;
import org.apache.commons.codec.binary.Base64;

import org.apache.commons.lang3.StringEscapeUtils;
import retrofit2.Call;
import retrofit2.Callback;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;




public class SendToMany implements RequestHandler<AwsProxyRequest, AwsProxyResponse> {

    public static void main(String[] args) {
        // Prints "Hello, World" to the terminal window.
        System.out.println("Hello, World");
        String values = "eyJyZXF1ZXN0VHlwZSI6InBvc3RlZFJlc3BvbnNlIiwic291cmNlVXNlcklkIjoiMjczIiwidGFyZ2V0VXNlcklkIjoiYXBpTG9va1VwIiwic3ViamVjdElkIjoiNjQwIiwic3ViamVjdFR5cGUiOiJSRVNQT05TRSIsIm1lZGlhVHlwZSI6IklNQUdFIiwiZW1haWwiOm51bGwsInNvdXJjZURlZXBMaW5rVXJsIjoiZGV2bWF2ZXJpY2s6Ly9tYXZlcmljay91c2VyLzI3MyIsInRhcmdldERlZXBMaW5rVXJsIjoiZGV2bWF2ZXJpY2s6Ly9tYXZlcmljay9yZXNwb25zZS82NDAiLCJub3RpZmljYXRpb25Db3B5IjoiQ2hlY2tvdXQgJXMncyBuZXcgcmVzcG9uc2UgdG8gJXMiLCJvd25lck5vdGlmaWNhdGlvbkNvcHkiOiIiLCJ0YXJnZXRVc2VycyI6bnVsbCwiY2VsZWJyYXRpb24iOm51bGwsImRldk1vZGUiOiJ0cnVlIn0=";
        String processed = "{\\\"requestType\\\":\\\"postedResponse\\\",\\\"sourceUserId\\\":\\\"273\\\",\\\"targetUserId\\\":\\\"apiLookUp\\\",\\\"subjectId\\\":\\\"640\\\",\\\"subjectType\\\":\\\"RESPONSE\\\",\\\"mediaType\\\":\\\"IMAGE\\\",\\\"email\\\":null,\\\"sourceDeepLinkUrl\\\":\\\"devmaverick:\\/\\/maverick\\/user\\/273\\\",\\\"targetDeepLinkUrl\\\":\\\"devmaverick:\\/\\/maverick\\/response\\/640\\\",\\\"notificationCopy\\\":\\\"Checkout %s\\'s new response to %s\\\",\\\"ownerNotificationCopy\\\":\\\"\\\",\\\"targetUsers\\\":null,\\\"celebration\\\":null,\\\"devMode\\\":\\\"true\\\"}";
//        String escaped = org.apache.commons.lang3.StringEscapeUtils.escapeJava(processed);
        String escaped = StringEscapeUtils.unescapeJava(processed);
        byte[] decodedValue = Base64.decodeBase64(values.getBytes());

//        System.out.println("escaped : " +  escaped);
        System.out.println("processed : " +  processed);
        System.out.println("decodedValue.toString() : " + decodedValue.toString());



        LeanplumRequest lpRequest = null;


        try {
            LeanplumRequest readValue = ExternalHelper.getInstance().getMapper().readValue( escaped, LeanplumRequest.class);
            System.out.println("readValue" + readValue.getSourceUserId());
            lpRequest =   ExternalHelper.getInstance().getMapper().readValue(Base64.decodeBase64(values), LeanplumRequest.class);
            System.out.println(lpRequest.getRequestType());
        } catch (IOException e) {
            e.printStackTrace();
        }


        ExternalHelper.getInstance().printObject("KinesisEvent PARSED : "  , lpRequest);




    }

    private int numRequests = 0;
    String pushMessageId_general = System.getenv("pushMessageId_general");
    String pushMessageId_follow = System.getenv("pushMessageId_follow");
    String pushMessageId_post = System.getenv("pushMessageId_posts");
    String pushMessageId_priority = System.getenv("pushMessageId_priority");
    private String appInboxMessageId = "456";
    private String appInboxMessageId_priority = "123";

    private Response responseObject;
    private Challenge challengeObject;

    public AwsProxyResponse handleKinesis(KinesisEvent request, Context context) {

        startTime = System.currentTimeMillis();

        try {
            System.out.println("Starting Up!");
            if (System.getenv("devMode") != null) {

                ExternalHelper.setDevMode(Boolean.parseBoolean(System.getenv("devMode")));

            }
            AwsProxyResponse response = new AwsProxyResponse(200);
            ExternalHelper.getInstance().printObject("request Received :", request);
            System.out.println("Receiving Records: " + request.getRecords().size());
            for (int i = 0; i < request.getRecords().size() ; i++) {

                ByteBuffer buffer = request.getRecords().get(i).getKinesis().getData();
                String dataString = new String(buffer.array());
                String escaped = StringEscapeUtils.unescapeJava(dataString);
                LeanplumRequest lpRequest = null;
                System.out.println("Data From Kinesis Records: " + dataString);
                try {
                    lpRequest = ExternalHelper.getInstance().getMapper().readValue(escaped, LeanplumRequest.class);
//                    if (ExternalHelper.isDevMode()) {

                        ExternalHelper.getInstance().printObject("Processed from Kinesis:", lpRequest);


//                    }


                } catch (IOException e) {
                    e.printStackTrace();
                }
//                if (true) {
//
//                   continue;
//
//                }

                /// INITIALIZE VARIABLES

                appInboxMessageId = System.getenv("appInboxMessageId");
                appInboxMessageId_priority = System.getenv("appInboxMessageId_priority");
                if (lpRequest == null) {
                    return response;
                }

                long currentTime =  System.currentTimeMillis();

                if (currentTime - startTime  < timeout_ms) {

                    System.out.println("Enough time to begin work remaining:  " + (timeout_ms - (currentTime - startTime)  ));
                    doWork(lpRequest);

                } else {

                    System.out.println("currentTime:" + (currentTime ) );
                    System.out.println("startTime:" + (startTime ) );
                    System.out.println("Not Enough time, stopping work:" + (currentTime - startTime) );

                }

            }
            return new AwsProxyResponse(200);

        } catch (Exception e) {

            System.out.println("Failed Somewhere: " + e.getMessage());

        } finally {

            return new AwsProxyResponse(200);

        }
    }
        /***
         * Lambda Function entry point
         * @param request
         * @param context
         * @return
         */
    public AwsProxyResponse handleRequest(AwsProxyRequest request, Context context) {

        System.out.println("Starting Up");
        ExternalHelper.getInstance().printObject("request Received :", request);

        if (System.getenv("devMode") != null) {

            ExternalHelper.setDevMode(Boolean.parseBoolean(System.getenv("devMode")));

        }

        /// INITIALIZE VARIABLES


        appInboxMessageId = System.getenv("appInboxMessageId");
        appInboxMessageId_priority = System.getenv("appInboxMessageId_priority");
        AwsProxyResponse response = new AwsProxyResponse(202);

        ///VALIDATE REQUEST
        LeanplumRequest lpRequest = parseMessage(request);

        if (lpRequest == null) {
            return response;
        }

        return doWork(lpRequest);

    }

    private long startTime;
    private long timeout_ms = 250000;
    /**
     * Main body of work taking a validated Leanplum Request object
     *
     * @param lpRequest
     * @return
     */
    private AwsProxyResponse doWork(LeanplumRequest lpRequest) {
        AwsProxyResponse response = new AwsProxyResponse(501);


        ///VALIDATE NOTIFICATION ID
        final String notificationId = getNotificationId(lpRequest);

        if (notificationId == null) {
            return response;
        }

        ///VALIDATE SOURCE USER
        User user = ExternalHelper.getInstance().getUserObject(lpRequest.getSourceUserId());

        if (user == null) {

            GenericResponseBody responseBody = new GenericResponseBody();
            responseBody.setMessage("Cannot find source user for: " + lpRequest.getSourceUserId());
            return new AwsProxyResponse(200, null, ExternalHelper.getInstance().getObjectString(responseBody));

        }

        ///BUILD MESSAGE BODY
        LeanplumMessage.LPValues values = getMessageValues(lpRequest, user);

        if (values == null){

            GenericResponseBody responseBody = new GenericResponseBody();
            responseBody.setMessage("Cannot build Message: " + lpRequest.getSourceUserId());
            return new AwsProxyResponse(200, null, ExternalHelper.getInstance().getObjectString(responseBody));

        }

        AmazonDynamoDB ddb = AmazonDynamoDBClientBuilder.defaultClient();
        DynamoDB dynamoDB = new DynamoDB(ddb);
        Table table = dynamoDB.getTable(ExternalHelper.getTableName());

        /// Send content owner a different notification
        String ownerNotificationCopy = values.getNotificationCopy();

//        System.out.println(" lpRequest.getOwnerNotificationCopy() != null: " + (lpRequest.getOwnerNotificationCopy() != null));
//        System.out.println("!lpRequest.getOwnerNotificationCopy().equals(\"\"): " + !lpRequest.getOwnerNotificationCopy().equals(""));
//        System.out.println("!values.getContentOwnerUserId().equals(user.getUserId()): " + !values.getContentOwnerUserId().equals(user.getUserId()));
//        System.out.println("!lpRequest.getTargetUserId().equals(\"apiLookUp\")): " + !lpRequest.getTargetUserId().equals("apiLookUp"));
//
//        System.out.println("user.getUserId(): " + user.getUserId());
//        System.out.println("values.getContentOwnerUserId(): " + values.getContentOwnerUserId());
        if (lpRequest.getOwnerNotificationCopy() != null && !lpRequest.getOwnerNotificationCopy().equals("") && (!values.getContentOwnerUserId().equals(user.getUserId()) || !lpRequest.getTargetUserId().equals("apiLookUp"))) {

//            if (ExternalHelper.isDevMode()) {

                System.out.println("Sending Owner Message: " + lpRequest.getOwnerNotificationCopy());

//            }

            if (!lpRequest.getRequestType().equals("mention")) {

                 if (lpRequest.getRequestType().equals("postedResponse") && responseObject.getChallengeTitle() != null ) {

                    ownerNotificationCopy = String.format(lpRequest.getOwnerNotificationCopy(), user.getUsername(), responseObject.getChallengeTitle());


                } else {

                    ownerNotificationCopy = String.format(lpRequest.getOwnerNotificationCopy(), user.getUsername());

                }


                sendOwnerMessages(lpRequest, notificationId, ownerNotificationCopy, values, table, pushMessageId_post, appInboxMessageId_priority);

            } else {

                values.setContentOwnerUserId(lpRequest.getTargetUserId());
                if (challengeObject != null ) {

                     ownerNotificationCopy = String.format(lpRequest.getOwnerNotificationCopy(), user.getUsername(), challengeObject.getTitle());


                } else  if (responseObject.getChallengeTitle() != null ) {

                    ownerNotificationCopy = String.format(lpRequest.getOwnerNotificationCopy(), user.getUsername(), responseObject.getChallengeTitle());


                } else {

                    ownerNotificationCopy = String.format(lpRequest.getOwnerNotificationCopy(), user.getUsername());

                }


                sendOwnerMessages(lpRequest, notificationId, ownerNotificationCopy, values, table, pushMessageId_priority, appInboxMessageId_priority);

            }



        } else {

//            if (ExternalHelper.isDevMode()) {
                System.out.println("Skipping Owner Message");
//            }

        }

        if (lpRequest.getRequestType().equals("challengeMention") ) {


            Item item = buildBasicDBItem(lpRequest, values);

            numRequests = challengeObject.getMentionUserIds().size() * 2;


            List<String> usersToNotify = challengeObject.getMentionUserIds();

//            if (ExternalHelper.isDevMode()) {
                System.out.println("Sending Challenge Mention to:  " + numRequests);
//            }
            List<LeanplumMessage> messagesToSend = new ArrayList<LeanplumMessage>();
            /// Run through all the followers of the source user and send messages, skip content owner if also a follower
            for (int i = 0 ; i < usersToNotify.size()  ; i++) {

                String id = usersToNotify.get(i);

                if (id.equals(values.getContentOwnerUserId())) {
                    numRequests -= 2;
                    continue;
                }


                List<LeanplumMessage> messages = getFollowerMessages(table, item, notificationId, id, values, true, true);

                if (messages != null && messages.size() > 0) {

                    messagesToSend.addAll(messages);

                }

            }

            System.out.println("Assembled messages:  " + messagesToSend.size());


            long currentTime =  System.currentTimeMillis();

            LeanplumMultiMessage multiMessage = new LeanplumMultiMessage();
            multiMessage.setData(messagesToSend);

            Call<Void> call = ExternalHelper.getInstance().createLeanplumMultiMessage(multiMessage);

            ExternalHelper.getInstance().printObject("attempting to send batch  ", multiMessage);


            try {
                call.execute();
            } catch (IOException e) {
                System.out.println("Fail Send Batch: " + notificationId );
                e.printStackTrace();
            }

            System.out.println("Ending Send Batch: " + notificationId );



            ddb.shutdown();
            GenericResponseBody responseBody = new GenericResponseBody();
            responseBody.setMessage("completed work forced by timeout : " + (currentTime - startTime  < timeout_ms));
            return new AwsProxyResponse(200, null, ExternalHelper.getInstance().getObjectString(responseBody));
        }

        if (lpRequest.getRequestType().equals("postedComment") || lpRequest.getRequestType().equals("mention") || lpRequest.getRequestType().equals("postedResponse")) {

            ddb.shutdown();
            GenericResponseBody responseBody = new GenericResponseBody();
            responseBody.setMessage("completed and not sending to followers");
            return new AwsProxyResponse(200, null, ExternalHelper.getInstance().getObjectString(responseBody));


        }

        Item item = buildBasicDBItem(lpRequest, values);

        numRequests = user.getFollowerUserIds().size() * 2;
//        if (ExternalHelper.isDevMode()) {
            System.out.println("Sending:  " + numRequests);
//        }

        List<String> usersToNotify = user.getFollowerUserIds();

        // temporarily remove notify other responders
        if (false && lpRequest.getRequestType().equals("postedResponse")) {

            System.out.println("postedResponse adding users:  " + usersToNotify.size() + usersToNotify);
            ExternalHelper.getInstance().addRespondersToList(usersToNotify, responseObject.getChallengeId());
            System.out.println("postedResponse after adding users:  " + usersToNotify.size());

        }

        List<LeanplumMessage> messagesToSend = new ArrayList<LeanplumMessage>();
        /// Run through all the followers of the source user and send messages, skip content owner if also a follower

       for (int i = 0 ; i < usersToNotify.size() ; i++) {

           String id = usersToNotify.get(i);

            if (id.equals(values.getContentOwnerUserId())) {
                numRequests -= 2;
                continue;
            }

           List<LeanplumMessage> messages = getFollowerMessages(table, item, notificationId, id, values, false, false);

            if (messages != null && messages.size() > 0) {

                messagesToSend.addAll(messages);

            }

        }

        System.out.println("Assembled messages:  " + messagesToSend.size());


        long currentTime =  System.currentTimeMillis();

        LeanplumMultiMessage multiMessage = new LeanplumMultiMessage();
        multiMessage.setData(messagesToSend);

        Call<Void> call = ExternalHelper.getInstance().createLeanplumMultiMessage(multiMessage);
        ExternalHelper.getInstance().printObject("attempting to send batch  ", multiMessage);

        try {
            call.execute();
        } catch (IOException e) {
            System.out.println("Fail Send Batch: " + notificationId );
            e.printStackTrace();
        }

        System.out.println("Ending Send Batch: " + notificationId );




//        /// Keep process alive until all messages have been sent
//        if (currentTime - startTime  < timeout_ms)  {
//
//
//        }

        System.out.println("Finished in time:  " + (currentTime - startTime  < timeout_ms));

        ddb.shutdown();
        GenericResponseBody responseBody = new GenericResponseBody();
        responseBody.setMessage("completed work");
        return new AwsProxyResponse(200, null, ExternalHelper.getInstance().getObjectString(responseBody));

    }

    /**
     * Dispatches async requests to leanplum to send in app and push notifications, when these return, they decrement the 'numRequests' count
     * <p>
     * Any failures are ignored and also decrement the count
     *
     * @param table
     * @param item
     * @param baseNotificationId
     * @param id
     * @param values
     */
    private List<LeanplumMessage> getFollowerMessages(Table table, Item item, String baseNotificationId, String id, LeanplumMessage.LPValues values, boolean isPriority, boolean oneOnly ) {

        List<LeanplumMessage> messagesToSend = new ArrayList<LeanplumMessage>();
        values.setBadgeNumber(getBadgeNumber(table, id));
        LeanplumMessage message = new LeanplumMessage();

        message.setUserId(id);
        message.setValues(values);

        final String newId = baseNotificationId + message.getUserId();

        if (oneOnly) {
            Item existingItem = table.getItem("id", newId);
            if (existingItem != null) {

//                if (ExternalHelper.isDevMode()) {
                    System.out.println("Message already exists: Skipping:  " + newId);
//                }
                numRequests = 0;
                return null;

            }
        }


        item.withPrimaryKey("id", newId  )
                .withString("notificationCopy", values.getNotificationCopy())
                .withString("targetUserId", message.getUserId());
        table.putItem(item);

        message.setMessageId(pushMessageId_follow);

        if (isPriority) {

            message.setMessageId(pushMessageId_priority);

        }

        messagesToSend.add(message);

        LeanplumMessage inAppMessage = message.clone(appInboxMessageId);
        inAppMessage.setMessageId(appInboxMessageId);
        if (isPriority) {

            inAppMessage.setMessageId(appInboxMessageId_priority);

        }

        messagesToSend.add(inAppMessage);
        return  messagesToSend;

    }

    /**
     * Read in Aws Proxy request and return Leanplum Request object
     *
     * @param request
     * @return
     */
    private LeanplumRequest parseMessage(AwsProxyRequest request) {
        LeanplumRequest lpRequest = null;
        try {

            lpRequest = ExternalHelper.getInstance().getMapper().readValue(request.getBody(), LeanplumRequest.class);

        } catch (IOException e) {

            System.out.println("Failed to parse Leanplum Request");
            e.printStackTrace();
            return null;

        }

        ExternalHelper.getInstance().printObject("Request received from leanplum: ", lpRequest);

        if (lpRequest.getDevMode() != null) {

            if (ExternalHelper.isDevMode()) {
                System.out.println("DevMode Override Set: " + Boolean.parseBoolean(lpRequest.getDevMode()));
            }
            ExternalHelper.setDevMode(Boolean.parseBoolean(lpRequest.getDevMode()));

        }

        return lpRequest;

    }

    /**
     * Build a semi-unique notification id string for this notification
     *
     * @param lpRequest
     * @return
     */
    private String getNotificationId(LeanplumRequest lpRequest) {

        String notificationId = null;
        if (lpRequest.getRequestType() != null) {

            if (lpRequest.getRequestType().equals("postedComment")) {

                notificationId = lpRequest.getSourceUserId() + lpRequest.getRequestType() + "on" + lpRequest.getSubjectType() + lpRequest.getSubjectId() + "to";

            } else {

                notificationId = lpRequest.getSourceUserId() + lpRequest.getRequestType() + lpRequest.getSubjectId() + "to";

            }

        }

        System.out.println("Building Notification: " + notificationId);

        return notificationId;

    }

    /**
     * Populate a lpValues object, based on the request and event creator user object
     *
     * @param lpRequest
     * @param user
     * @return Populated values object
     */
    private LeanplumMessage.LPValues getMessageValues(LeanplumRequest lpRequest, User user) {

        LeanplumMessage.LPValues values = new LeanplumMessage.LPValues();
        values.setTargetDeepLinkUrl(lpRequest.getTargetDeepLinkUrl());
        values.setSourceDeepLinkUrl(lpRequest.getSourceDeepLinkUrl());
        values.setCelebrationColor(lpRequest.getCelebration().getColor_rrggbbaa());
        values.setCelebrationImage(lpRequest.getCelebration().getImage());
        values.setCelebrationCopy1(lpRequest.getCelebration().getCopy1());
        values.setCelebrationCopy2(lpRequest.getCelebration().getCopy2());

        if (lpRequest.getSubjectType() != null) {

            if (lpRequest.getSubjectType().equalsIgnoreCase("response")) {

                lpRequest.setSubjectType("response");
                responseObject = ExternalHelper.getInstance().getResponseObject(lpRequest.getSubjectId());
                if ( responseObject == null ) {
                    return  null;
                }
                challengeObject = new Challenge();
                challengeObject.setTitle(responseObject.getChallengeTitle());
                challengeObject.setChallengeId(responseObject.getChallengeId());

                values.setTargetImageUrl(responseObject.getImageURL());
                values.setSourceImageUrl(user.getAvatarUrl());
                if ( lpRequest.getNotificationCopy() != null ) {

                    values.setNotificationCopy(String.format(lpRequest.getNotificationCopy(), user.getUsername(), responseObject.getChallengeTitle()));

                    if (responseObject.getChallengeTitle() == null) {

                        values.setNotificationCopy(String.format(lpRequest.getNotificationCopyNoChallenge(), user.getUsername()));

                    }

                }

                values.setContentOwnerUserId(responseObject.getUserId());

                if (lpRequest.getRequestType().equals("postedResponse") ){


                    values.setContentOwnerUserId(responseObject.getChallengeCreatorUserId());

                }

            } else if (lpRequest.getSubjectType().equalsIgnoreCase("challenge")) {

                lpRequest.setSubjectType("challenge");
                challengeObject = ExternalHelper.getInstance().getChallengeObject(lpRequest.getSubjectId());

                if ( challengeObject == null ) {
                    return  null;
                }
                values.setTargetImageUrl(challengeObject.getImageUrl());


                values.setSourceImageUrl(user.getAvatarUrl());
                if ( lpRequest.getNotificationCopy() != null ) {

                    values.setNotificationCopy(String.format(lpRequest.getNotificationCopy(), user.getUsername(), challengeObject.getTitle()));

                }

                values.setContentOwnerUserId(challengeObject.getUserId());

            }

        }

        ExternalHelper.getInstance().printObject("Returning assembled values: ", values);
        return values;

    }


    /**
     * Search table for unread count off of secondary index, iterate through and add numbers together
     *
     * @param table
     * @param userId
     * @return value to be set as app icon badge number
     */
    private int getBadgeNumber(Table table, String userId) {

        Iterator<Item> iter = ExternalHelper.getInstance().getUnreadNotifications(table, userId).iterator();
        int i = 1;
        while (iter.hasNext()) {

            iter.next();
            i++;

        }

        System.out.println("Assigning badge number of: " + i + " : for user: " + userId);

        return i;

    }

    private Item buildBasicDBItem(LeanplumRequest lpRequest, LeanplumMessage.LPValues values) {

        Item item = new Item().withPrimaryKey("id", "id")
                .withLong("timeStamp", System.currentTimeMillis())
                .withString("subjectId", lpRequest.getSubjectId())
                .withString("subjectType", lpRequest.getSubjectType())
                .withString("requestType", lpRequest.getRequestType())
                .withString("sourceUserId", lpRequest.getSourceUserId())
                .withString("targetImageUrl", values.getTargetImageUrl())
                .withString("targetDeepLinkUrl", values.getTargetDeepLinkUrl())
                .withString("sourceImageUrl", values.getSourceImageUrl())
                .withString("sourceDeepLinkUrl", values.getSourceDeepLinkUrl())
                .withBoolean("unread", true);

        return item;

    }

    private String trimImageUrl(String url) {
        String returnValue = url.replaceFirst("https://","");
        return  returnValue.replaceFirst("http://","");
    }

    /**
     * Send a special message to the owner of the content being interacted with
     *
     * @param lpRequest
     * @param notificationId
     * @param ownerNotificationCopy
     * @param values
     * @param table
     * @return a AWS dynamo item that is mostly populated
     */
    private void sendOwnerMessages(LeanplumRequest lpRequest, String notificationId, String ownerNotificationCopy, LeanplumMessage.LPValues values, Table table, String pushId, String inAppId) {

        LeanplumMessage message = new LeanplumMessage();

        String originalCopy = values.getNotificationCopy();
        values.setNotificationCopy(ownerNotificationCopy);
        values.setBadgeNumber(getBadgeNumber(table, values.getContentOwnerUserId()));

        values.setImage_url(trimImageUrl(values.getTargetImageUrl()));

        message.setUserId(values.getContentOwnerUserId());
        message.setValues(values);
        message.setMessageId(pushId);

        Item item = buildBasicDBItem(lpRequest, values)
                .withPrimaryKey("id", notificationId + "owner" + message.getValues().getContentOwnerUserId() + "_" + System.currentTimeMillis())
                .withString("notificationCopy", ownerNotificationCopy)
                .withString("targetUserId", message.getUserId());

        table.putItem(item);
        ExternalHelper.getInstance().sendLeanplumMessage(message);
        message.setMessageId(inAppId);
        ExternalHelper.getInstance().sendLeanplumMessage(message);
        values.setNotificationCopy(originalCopy);



    }

    /**
     * Continuous check to determine if all messages have completed
     *
     * @return numRequests <= 0
     */
    private boolean isDone() {
        if (ExternalHelper.isDevMode()) {
            System.out.println("isDone: " + (numRequests <= 0));
        }
        return numRequests <= 0;

    }

}