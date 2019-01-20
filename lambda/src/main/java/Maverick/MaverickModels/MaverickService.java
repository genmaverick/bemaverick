package Maverick.MaverickModels;

import retrofit2.Call;
import retrofit2.http.*;

public interface MaverickService {

    @GET("/v1/user/followers")
    Call<MaverickAPIResponse> getUser(@Query("accessToken") String token, @Query("userId") String userId, @Query("appKey") String appKey, @Query("basic") String basic );


    @GET("/v1/response/details")
    Call<MaverickAPIResponse> getResponse(@Query("accessToken") String token, @Query("responseId") String responseId, @Query("appKey") String appKey );


    @GET("/v1/challenge/details")
    Call<MaverickAPIResponse> getChallenge(@Query("accessToken") String token, @Query("challengeId") String challengeId, @Query("appKey") String appKey );


    @GET("/v1/user/followers")
    Call<MaverickAPIResponse> getFollowers(@Query("accessToken") String token, @Query("userId") String userId, @Query("appKey") String appKey );


    @GET("/v1/challenge/responses")
    Call<MaverickAPIResponse> getResponsesForChallenge(@Query("accessToken") String token, @Query("challengeId") String challengeId, @Query("appKey") String appKey, @Query("count") String count);
}
