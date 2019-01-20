package Maverick;

import Maverick.LeanplumModels.LeanplumMessage;
import Maverick.LeanplumModels.LeanplumMultiMessage;
import Maverick.LeanplumModels.LeanplumService;
import Maverick.MaverickModels.*;
import com.amazonaws.services.dynamodbv2.document.Index;
import com.amazonaws.services.dynamodbv2.document.ItemCollection;
import com.amazonaws.services.dynamodbv2.document.QueryOutcome;
import com.amazonaws.services.dynamodbv2.document.Table;
import com.amazonaws.services.dynamodbv2.document.spec.QuerySpec;
import com.amazonaws.services.dynamodbv2.document.utils.NameMap;
import com.amazonaws.services.dynamodbv2.document.utils.ValueMap;
import com.fasterxml.jackson.annotation.JsonAutoDetect;
import com.fasterxml.jackson.annotation.PropertyAccessor;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import okhttp3.OkHttpClient;
import retrofit2.Call;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.ObjectInput;
import java.io.ObjectInputStream;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.TimeUnit;

public class ExternalHelper {

    private static ExternalHelper instance;
    private ObjectMapper mapper;
    private String maverickToken;
    private String appKey;
    private String maverickBaseURL;
    private String apiVersion;


    private static final String clientKey_dev = "prod_8KchwQ1kcWuM1dFI1kbXtQRQVB79Sn9w5jVd6u14Jjg";
    private static final String appId_dev = "app_0SPllvo97hhhTnIDUhOdGD5LSwOZQ519gBpej6zfYfs";
    private String lpBaseURL = "https://www.leanplum.com/";
    private static final String clientKey_prod = "prod_eFC13iWoyQ7a1kjrZBioaRTNkgOTfpgZmJFsZM41JSM";
    private static final String appId_prod = "app_R29Nd2LrIcAQmnTH5W5BhWC1GkuwkemIk8iersuMRww";
    private LeanplumService leanplumService;
    private MaverickService maverickService;
    private static boolean devMode = false;
    private static final String notificationTableName_dev = "notifications";
    private static final String notificationTableName_prod = "Notifications-Prod";


    public static void setDevMode(boolean devMode) {

        ExternalHelper.devMode = devMode;
        instance = null;
        getInstance();

    }

    public static String getTableName() {

       return isDevMode() ? notificationTableName_dev : notificationTableName_prod;

    }

    public static String getAppId() {

        return isDevMode() ? appId_dev : appId_prod;

    }

    public static String getClientKey() {

        return isDevMode() ? clientKey_dev : clientKey_prod;

    }


    static public ExternalHelper getInstance() {
        if (instance == null) {
            instance = new ExternalHelper();
            instance.mapper = new ObjectMapper();
            instance.mapper.setVisibility(PropertyAccessor.ALL, JsonAutoDetect.Visibility.NONE);
            instance.mapper.setVisibility(PropertyAccessor.FIELD, JsonAutoDetect.Visibility.ANY);
            instance.initializeService();
        }
        return instance;
    }

    public ObjectMapper getMapper() {
        return mapper;
    }


    private void initializeService() {

        maverickBaseURL = "https://api.bemaverick.com/v1/";
        maverickToken = System.getenv("maverickToken");

        if (devMode) {

            maverickBaseURL = "https://dev-api.bemaverick.com/v1/";
            maverickToken = System.getenv("maverickTokenDev");

        }

        appKey = System.getenv("appKey");
        apiVersion = System.getenv("apiVersion");
        Retrofit retrofit = new Retrofit.Builder()
                .baseUrl(maverickBaseURL)
                .addConverterFactory(GsonConverterFactory.create())
                .build();

        maverickService = retrofit.create(MaverickService.class);
        OkHttpClient okHttpClient = new OkHttpClient.Builder()
                .readTimeout(60, TimeUnit.SECONDS)
                .connectTimeout(60, TimeUnit.SECONDS)
                .build();

        retrofit = new Retrofit.Builder()
                .baseUrl(lpBaseURL)
                .client(okHttpClient)
                .addConverterFactory(GsonConverterFactory.create())
                .build();

        leanplumService = retrofit.create(LeanplumService.class);
    }


    public Call<Void> createLeanplumMessage(LeanplumMessage message) {

        return leanplumService.sendMessage(getAppId(), getClientKey(), apiVersion, message);

    }


    public Call<Void> createLeanplumMultiMessage(LeanplumMultiMessage message) {

        return leanplumService.sendMultiMessage(getAppId(), getClientKey(), apiVersion, message);

    }

    public boolean sendLeanplumMessage(LeanplumMessage message) {

        try {

            printObject("Sending Leanplum Message", message);
            retrofit2.Response retrofitResponse = createLeanplumMessage(message).execute();
            return retrofitResponse.code() == 200;


        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }

    }


    public void addRespondersToList(List<String> users, String challengeId) {

        try {

            retrofit2.Response retrofitResponse = maverickService.getResponsesForChallenge(maverickToken, challengeId, appKey, "200").execute();
            MaverickAPIResponse maverickAPIResponse = (MaverickAPIResponse) retrofitResponse.body();

            Challenge challenge = maverickAPIResponse.getChallenges().get(challengeId);
            if ( challenge != null ) {

                String[] usersToAdd = challenge.getSearchResults().getResponses().getResponseIds();

                for (String id : usersToAdd) {

                    if (!users.contains(id)) {

                        users.add(id);

                    }

                }

            }

            printObject("users to add: ",challenge.getSearchResults().getResponses().getResponseIds());

        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public Response getResponseObject(String responseId) {

        Response responseObject = new Response();

        try {

            retrofit2.Response retrofitResponse = maverickService.getResponse(maverickToken, responseId, appKey).execute();
            MaverickAPIResponse maverickAPIResponse = (MaverickAPIResponse) retrofitResponse.body();
            System.out.println("Attempt to fetch Response Object for: " + responseId);
            if (maverickAPIResponse != null && maverickAPIResponse.getResponses() != null) {

                responseObject = maverickAPIResponse.getResponses().get(responseId);

                if (responseObject != null) {

                    Challenge challenge = null;

                    if (responseObject.getChallengeId() != null) {

                        challenge = maverickAPIResponse.getChallenges().get(responseObject.getChallengeId());

                    }

                    Image image = maverickAPIResponse.getImages().get(responseObject.getCoverImageId());
                    if (image != null) {

                        responseObject.setImageURL(image.getUrl());

                    }

                    if (challenge != null) {

                        responseObject.setChallengeCreatorUserId(challenge.getUserId());
                        responseObject.setChallengeTitle(challenge.getTitle());

                    }
                    System.out.println("responseObject Object: " + mapper.writeValueAsString(responseObject));

                } else {

                    System.out.println("responseObject Object null - id:" + responseId);
                }
            }

        } catch (IOException e) {
            e.printStackTrace();
        }

        return responseObject;

    }

    public Challenge getChallengeObject(String challengeId) {

        Challenge challengeObject = new Challenge();


        try {
            System.out.println("Attempt to fetch Challenge Object for: " + challengeId);

            retrofit2.Response retrofitResponse = maverickService.getChallenge(maverickToken, challengeId, appKey).execute();
            MaverickAPIResponse maverickAPIResponse = (MaverickAPIResponse) retrofitResponse.body();


            if (maverickAPIResponse.getChallenges() != null &&  maverickAPIResponse.getChallenges().get(challengeId) != null) {

                challengeObject = maverickAPIResponse.getChallenges().get(challengeId);

                Image image = maverickAPIResponse.getImages().get(challengeObject.getCardImageId());
                if (image != null) {
                    challengeObject.setImageUrl(image.getUrl());
                }
                System.out.println("challengeObject Object: " + mapper.writeValueAsString(challengeObject));
            } else {
                System.out.println("responseObject Object null - id:" + challengeId);
            }


        } catch (IOException e) {
            e.printStackTrace();
        }

        return challengeObject;

    }

    public void printObject(String title, Object object) {

        try {


            System.out.println(title + " Object: " + mapper.writeValueAsString(object));

        } catch (JsonProcessingException e) {

            e.printStackTrace();
        }

    }

    public String getObjectString(Object object) {
        try {
            return ExternalHelper.getInstance().getMapper().writeValueAsString(object);
        } catch (JsonProcessingException e) {
            return  null;
        }
    }

    public User getUserObject(String userId) {

        User userResponse = new User();
        System.out.println("Attempt to fetch user Object for: " + userId);
        try {

            retrofit2.Response retrofitResponse = maverickService.getUser(maverickToken, userId, appKey, "1").execute();
            MaverickAPIResponse maverickAPIResponse = (MaverickAPIResponse) retrofitResponse.body();

            if ( maverickAPIResponse == null ) {
                System.out.println("Failed to fetch user Object for: " + userId);
                return userResponse;
            }
            if (maverickAPIResponse.getUsers() != null && maverickAPIResponse.getUsers().get(userId) != null) {

                userResponse = maverickAPIResponse.getUsers().get(userId);
                if (userResponse.getProfileImageId() != null) {
                    Image image = maverickAPIResponse.getImages().get(userResponse.getProfileImageId());
                    if (image != null) {
                        userResponse.setAvatarUrl(image.getUrl());
                    }
                }
                System.out.println("userResponse Object: " + mapper.writeValueAsString(userResponse));
            } else {
                System.out.println("unable to fetch user : " + userId + " devmode: " + devMode);
            }


        } catch (IOException e) {
            e.printStackTrace();
        }

        return userResponse;

    }

    public static boolean isDevMode() {
        return devMode;
    }

    public ItemCollection<QueryOutcome> getUnreadNotifications(Table table, String targetUserId) {
        Index index = table.getIndex("targetUserId-index");

        QuerySpec spec = new QuerySpec()
                .withKeyConditionExpression("#id = :v_id")
                .withNameMap(new NameMap()
                        .with("#id", "targetUserId"))
                .withValueMap(new ValueMap()
                        .withString(":v_id", targetUserId).withBoolean(":v_un", true))
                .withFilterExpression("unread = :v_un");

        return index.query(spec);
    }

    /* De serialize the byte array to object */
    public static Object getObject(byte[] byteArr) throws IOException, ClassNotFoundException {
        ByteArrayInputStream bis = new ByteArrayInputStream(byteArr);
        ObjectInput in = new ObjectInputStream(bis);
        return in.readObject();
    }


}
