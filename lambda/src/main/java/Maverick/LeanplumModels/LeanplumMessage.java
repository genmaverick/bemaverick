package Maverick.LeanplumModels;

public class LeanplumMessage {

    String messageId;
    String userId;
    String action;
    Boolean force;
    LPValues values;
    long time;

    public LeanplumMessage() {

        action = "sendMessage";
        force = false;
        time = System.currentTimeMillis();

    }


    public long getTime() {
        return time;
    }

    public void setTime(long time) {
        this.time = time;
    }

    public LeanplumMessage clone(String messageId) {

        LeanplumMessage newMessage = new LeanplumMessage();

        newMessage.setMessageId(messageId);
        newMessage.setUserId(userId);
        newMessage.setAction(action);
        newMessage.setForce(force);
        newMessage.setValues(values);
        newMessage.setTime(time);
        return newMessage;
    }

    public String getMessageId() {
        return messageId;
    }

    public void setMessageId(String messageId) {
        this.messageId = messageId;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public Boolean getForce() {
        return force;
    }

    public void setForce(Boolean force) {
        this.force = force;
    }

    public LPValues getValues() {
        return values;
    }

    public void setValues(LPValues values) {
        this.values = values;
    }


    public static class LPValues {

        String contentOwnerUserId;
        String sourceDeepLinkUrl;
        String targetDeepLinkUrl;
        String sourceImageUrl;
        String targetImageUrl;
        String celebrationCopy1;
        String celebrationCopy2;

        String celebrationColor;
        String celebrationImage;
        boolean celebrationEnabled;

        String image_url;


        public String getImage_url() {
            return image_url;
        }

        public void setImage_url(String image_url) {
            this.image_url = image_url;
        }

        public boolean isCelebrationEnabled() {
            return celebrationEnabled;
        }


        public void setCelebrationEnabled(boolean celebrationEnabled) {
            this.celebrationEnabled = celebrationEnabled;
        }

        public String getCelebrationColor() {
            return celebrationColor;
        }

        public void setCelebrationColor(String celebrationColor) {
            this.celebrationColor = celebrationColor;
        }

        public String getCelebrationImage() {
            return celebrationImage;
        }

        public void setCelebrationImage(String celebrationImage) {
            this.celebrationImage = celebrationImage;
        }

        int badgeNumber = 0;

        public String getCelebrationCopy1() {
            return celebrationCopy1;
        }

        public void setCelebrationCopy1(String celebrationCopy1) {
            if (celebrationCopy1 != null) {
                setCelebrationEnabled(true);
            }
            this.celebrationCopy1 = celebrationCopy1;
        }

        public String getCelebrationCopy2() {
            return celebrationCopy2;
        }

        public void setCelebrationCopy2(String celebrationCopy2) {
            this.celebrationCopy2 = celebrationCopy2;
        }

        public int getBadgeNumber() {
            return badgeNumber;
        }

        public void setBadgeNumber(int badgeNumber) {
            this.badgeNumber = badgeNumber;
        }

        String notificationCopy;

        public String getContentOwnerUserId() {
            return contentOwnerUserId;
        }

        public void setContentOwnerUserId(String contentOwnerUserId) {
            this.contentOwnerUserId = contentOwnerUserId;
        }

        public String getNotificationCopy() {
            return notificationCopy;
        }

        public void setNotificationCopy(String notificationCopy) {
            this.notificationCopy = notificationCopy;
        }

        public String getSourceDeepLinkUrl() {
            if (sourceDeepLinkUrl == null) {
                return "none";
            }
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

        public String getSourceImageUrl() {
            if (sourceImageUrl == null) {
                return "none";
            }
            return sourceImageUrl;
        }

        public void setSourceImageUrl(String sourceImageUrl) {
            this.sourceImageUrl = sourceImageUrl;
        }

        public String getTargetImageUrl() {
            if (targetImageUrl == null) {
                return "none";
            }
            return targetImageUrl;
        }

        public void setTargetImageUrl(String targetImageUrl) {
            this.targetImageUrl = targetImageUrl;
        }
    }

}
