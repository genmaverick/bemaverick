package Maverick.MaverickModels;

import java.util.HashMap;

public class MaverickAPIResponse {

    HashMap<String, Image> images;
    HashMap<String, User> users;
    HashMap<String, Response> responses;
    HashMap<String, Challenge> challenges;

    public HashMap<String, Response> getResponses() {
        return responses;
    }

    public void setResponses(HashMap<String, Response> responses) {
        this.responses = responses;
    }

    public HashMap<String, Challenge> getChallenges() {
        return challenges;
    }

    public void setChallenges(HashMap<String, Challenge> challenges) {
        this.challenges = challenges;
    }

    public HashMap<String, Image> getImages() {
        return images;
    }

    public void setImages(HashMap<String, Image> images) {
        this.images = images;
    }

    public HashMap<String, User> getUsers() {
        return users;
    }

    public void setUsers(HashMap<String, User> users) {
        this.users = users;
    }

}
