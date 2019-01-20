package Maverick.MaverickModels;

import java.util.List;

public class Challenge {

    String userId;
    String challengeId;
    String title;
    String description;
    String cardImageId;
    List<String> mentionUserIds;
    String imageUrl;
    SearchResults searchResults;


    public List<String> getMentionUserIds() {

        return mentionUserIds;

    }

    public void setMentionUserIds(List<String> mentionUserIds) {

        this.mentionUserIds = mentionUserIds;

    }

    public SearchResults getSearchResults() {
        return searchResults;
    }

    public void setSearchResults(SearchResults searchResults) {
        this.searchResults = searchResults;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getChallengeId() {
        return challengeId;
    }

    public void setChallengeId(String challengeId) {
        this.challengeId = challengeId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getCardImageId() {
        return cardImageId;
    }

    public void setCardImageId(String cardImageId) {
        this.cardImageId = cardImageId;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }
}