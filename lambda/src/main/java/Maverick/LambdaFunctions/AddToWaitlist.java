package Maverick.LambdaFunctions;

import Maverick.ExternalHelper;
import Maverick.LeanplumModels.LeanplumRequest;
import com.amazonaws.serverless.proxy.model.AwsProxyRequest;
import com.amazonaws.serverless.proxy.model.AwsProxyResponse;
import com.amazonaws.services.dynamodbv2.AmazonDynamoDB;
import com.amazonaws.services.dynamodbv2.AmazonDynamoDBClientBuilder;
import com.amazonaws.services.dynamodbv2.document.DynamoDB;
import com.amazonaws.services.dynamodbv2.document.Item;
import com.amazonaws.services.dynamodbv2.document.Table;
import com.amazonaws.services.lambda.runtime.Context;

import java.io.IOException;

public class AddToWaitlist {

    public AwsProxyResponse handleRequest(AwsProxyRequest request, Context context) {

        System.out.println("Starting: AddToWaitlist");

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

        if (lpRequest.getEmail() != null) {

            AmazonDynamoDB ddb = AmazonDynamoDBClientBuilder.defaultClient();
            DynamoDB dynamoDB = new DynamoDB(ddb);

            Table table = dynamoDB.getTable("WaitList");
            Item item = new Item().withPrimaryKey("email", lpRequest.getEmail()).withLong("timeStamp", System.currentTimeMillis());
            table.putItem(item);


        }

        return new AwsProxyResponse(200);


    }
}
