package Maverick.LambdaFunctions;

import Maverick.ExternalHelper;
import Maverick.LeanplumModels.LeanplumRequest;
import com.amazonaws.serverless.proxy.model.AwsProxyRequest;
import com.amazonaws.serverless.proxy.model.AwsProxyResponse;
import com.amazonaws.services.dynamodbv2.AmazonDynamoDB;
import com.amazonaws.services.dynamodbv2.AmazonDynamoDBClientBuilder;
import com.amazonaws.services.dynamodbv2.document.*;
import com.amazonaws.services.dynamodbv2.document.spec.QuerySpec;
import com.amazonaws.services.dynamodbv2.document.spec.UpdateItemSpec;
import com.amazonaws.services.dynamodbv2.document.utils.NameMap;
import com.amazonaws.services.dynamodbv2.document.utils.ValueMap;
import com.amazonaws.services.dynamodbv2.model.ReturnValue;
import com.amazonaws.services.lambda.runtime.Context;

import java.io.IOException;
import java.util.HashMap;
import java.util.Iterator;

public class MarkAllRead {

    public AwsProxyResponse handleRequest(AwsProxyRequest request, Context context) {

        System.out.println("Starting: MarkAllRead");

        if (System.getenv("devMode") != null) {

            ExternalHelper.setDevMode(Boolean.parseBoolean(System.getenv("devMode")));

        }

        return doWork(request);

    }

    private AwsProxyResponse doWork(AwsProxyRequest request) {


        LeanplumRequest lpRequest = new LeanplumRequest();

        try {

            lpRequest = ExternalHelper.getInstance().getMapper().readValue(request.getBody(), LeanplumRequest.class);

        } catch (IOException e) {

            e.printStackTrace();
            return new AwsProxyResponse(501);

        }

        if (lpRequest.getDevMode() != null) {

            System.out.println("DevMode Override Set: " + Boolean.parseBoolean(lpRequest.getDevMode()));
            ExternalHelper.setDevMode(Boolean.parseBoolean(lpRequest.getDevMode()));

        }

//        if (ExternalHelper.isDevMode()) {

            ExternalHelper.getInstance().printObject("Request Received : " , lpRequest);

//        }

        if (lpRequest.getTargetUserId() != null) {

            AmazonDynamoDB ddb = AmazonDynamoDBClientBuilder.defaultClient();
            DynamoDB dynamoDB = new DynamoDB(ddb);
            System.out.println("Starting: To Read: " + lpRequest.getTargetUserId());

            Table table = dynamoDB.getTable(ExternalHelper.getTableName());

            System.out.println("Attempting to mark : " + getBadgeNumber(table, lpRequest.getTargetUserId()) + " as read");

            ItemCollection<QueryOutcome> items = ExternalHelper.getInstance().getUnreadNotifications(table, lpRequest.getTargetUserId());

            Iterator<Item> iter = items.iterator();

            while (iter.hasNext()) {
                Item item = iter.next();
                UpdateItemSpec updateItemSpec = new UpdateItemSpec().withPrimaryKey("id", item.getString("id"))
                        .withReturnValues(ReturnValue.ALL_NEW).withUpdateExpression("set unread = :val1")
                        .withValueMap(new ValueMap().withBoolean(":val1", false));

                UpdateItemOutcome outcome = table.updateItem(updateItemSpec);

                // Check the response.
//                System.out.println("Printing item after conditional update to new attribute...");
//                System.out.println(outcome.getItem().toJSONPretty());
//
//                System.out.println(item.toJSONPretty());
            }


            System.out.println("Ended with : " + getBadgeNumber(table, lpRequest.getTargetUserId()) + " : remaining as unread");

        }

        return new AwsProxyResponse(200);


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
        int i = 0;
        while (iter.hasNext()) {

            iter.next();
            i++;

        }

        return i;

    }

}
