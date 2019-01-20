package Maverick.LeanplumModels;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.io.Serializable;
import java.util.List;

@JsonIgnoreProperties(ignoreUnknown = true)
public class LeanplumRequest implements Serializable {

    String requestType;
    String sourceUserId;
    String targetUserId;
    String subjectId;
    String subjectType;
    String mediaType;
    String notificationCopyNoChallenge;
    String email;
    String sourceDeepLinkUrl;
    String targetDeepLinkUrl;
    String notificationCopy;
    String ownerNotificationCopy;
    List<String> targetUsers;

    Celebration celebration;

    public Celebration getCelebration() {
        if( celebration == null ){
            celebration = new Celebration();
        }
        return celebration;
    }


    public void setCelebration(Celebration celebration) {
        this.celebration = celebration;
    }

    String devMode;

    public String getNotificationCopyNoChallenge() {
        return notificationCopyNoChallenge;
    }

    public void setNotificationCopyNoChallenge(String notificationCopyNoChallenge) {
        this.notificationCopyNoChallenge = notificationCopyNoChallenge;
    }

    public String getMediaType() {
        return mediaType;
    }

    public void setMediaType(String mediaType) {
        this.mediaType = mediaType;
    }

    public String getRequestType() {
        return requestType;
    }

    public String getEmail() {
        return email;
    }

    public String getOwnerNotificationCopy() {
        return ownerNotificationCopy;
    }

    public void setOwnerNotificationCopy(String ownerNotificationCopy) {
        this.ownerNotificationCopy = ownerNotificationCopy;
    }

    public String getNotificationCopy() {
        return notificationCopy;
    }

    public String getDevMode() {
        return devMode;
    }

    public void setDevMode(String devMode) {
        this.devMode = devMode;
    }

    public void setNotificationCopy(String notificationCopy) {
        this.notificationCopy = notificationCopy;
    }

    public String getSubjectId() {
        return subjectId;
    }

    public void setSubjectId(String subjectId) {
        this.subjectId = subjectId;
    }

    public String getSubjectType() {
        return subjectType;
    }

    public void setSubjectType(String subjectType) {
        this.subjectType = subjectType;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setRequestType(String requestType) {
        this.requestType = requestType;
    }


    public String getSourceDeepLinkUrl() {
        return sourceDeepLinkUrl;
    }

    public void setSourceDeepLinkUrl(String sourceDeepLinkUrl) {
        this.sourceDeepLinkUrl = sourceDeepLinkUrl;
    }

    public String getTargetDeepLinkUrl() {
        return targetDeepLinkUrl;
    }

    public void setTargetDeepLinkUrl(String targetDeepLinkUrl) {
        this.targetDeepLinkUrl = targetDeepLinkUrl;
    }

    public String getSourceUserId() {
        if (sourceUserId == null ) {
            return "none";
        }
        return sourceUserId;
    }

    public void setSourceUserId(String sourceUserId) {
        this.sourceUserId = sourceUserId;
    }

    public String getTargetUserId() {
        return targetUserId;
    }

    public void setTargetUserId(String targetUserId) {
        this.targetUserId = targetUserId;
    }

    public List<String> getTargetUsers() {
        return targetUsers;
    }

    public void setTargetUsers(List<String> targetUsers) {
        this.targetUsers = targetUsers;
    }

    public static class Celebration {

        String copy1;
        String copy2;
        String color_rrggbbaa;
        String image;

        public boolean isValid() {

            return (color_rrggbbaa != null && copy1 != null && copy2 != null && image != null);
        }

        public String getColor_rrggbbaa() {
            return color_rrggbbaa;
        }

        public void setColor_rrggbbaa(String color_rrggbbaa) {
            this.color_rrggbbaa = color_rrggbbaa;
        }

        public String getImage() {
            return image;
        }

        public void setImage(String image) {
            this.image = image;
        }

        public String getCopy1() {
            return copy1;
        }

        public void setCopy1(String copy1) {
            this.copy1 = copy1;
        }

        public String getCopy2() {
            return copy2;
        }

        public void setCopy2(String copy2) {
            this.copy2 = copy2;
        }
    }
}
