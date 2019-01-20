package Maverick.MaverickModels;

public class Response {

    String userId;
    String responseId;
    String coverImageId;
    String imageURL;
    String challengeTitle;



    String challengeCreatorUserId;
    String challengeId;
    String imageId;
    Challenge challenge;

    public String getChallengeId() {
        return challengeId;
    }

    public void setChallengeId(String challengeId) {
        this.challengeId = challengeId;
    }

    public String getImageId() {
        return imageId;
    }

    public void setImageId(String imageId) {
        this.imageId = imageId;
    }

    public Challenge getChallenge() {
        return challenge;
    }

    public void setChallenge(Challenge challenge) {
        this.challenge = challenge;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getResponseId() {
        return responseId;
    }

    public void setResponseId(String responseId) {
        this.responseId = responseId;
    }

    public String getCoverImageId() {

        if (coverImageId == null) {

            return imageId;

        }

        return coverImageId;

    }

    public void setCoverImageId(String coverImageId) {
        this.coverImageId = coverImageId;
    }

    public String getImageURL() {
        return imageURL;
    }

    public void setImageURL(String imageURL) {
        this.imageURL = imageURL;
    }

    public String getChallengeTitle() {
        return challengeTitle;
    }

    public String getChallengeCreatorUserId() {
        return challengeCreatorUserId;
    }

    public void setChallengeCreatorUserId(String challengeCreatorUserId) {
        this.challengeCreatorUserId = challengeCreatorUserId;
    }

    public void setChallengeTitle(String challengeTitle) {
        this.challengeTitle = challengeTitle;
    }
}