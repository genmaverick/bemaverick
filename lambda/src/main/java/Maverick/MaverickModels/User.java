package Maverick.MaverickModels;

import java.util.List;

public class User {

    String userId;
    String username;
    String profileImageId;
    String avatarUrl;
    List<String> followerUserIds;

    public List<String> getFollowerUserIds() {
        return followerUserIds;
    }

    public void setFollowerUserIds(List<String> followerUserIds) {
        this.followerUserIds = followerUserIds;
    }

    public String getAvatarUrl() {
        if (avatarUrl == null) {
            return "none";
        }
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getProfileImageId() {
        return profileImageId;
    }

    public void setProfileImageId(String profileImageId) {
        this.profileImageId = profileImageId;
    }
}
