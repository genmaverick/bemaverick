package Maverick.LeanplumModels;

import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.POST;
import retrofit2.http.Query;

public interface LeanplumService {

    @POST("api")
    Call<Void> sendMessage( @Query("appId") String appId, @Query("clientKey") String clientKey, @Query("apiVersion") String apiVersion, @Body LeanplumMessage message );

    @POST("api")
    Call<Void> sendMultiMessage( @Query("appId") String appId, @Query("clientKey") String clientKey, @Query("apiVersion") String apiVersion, @Body LeanplumMultiMessage message );

}
