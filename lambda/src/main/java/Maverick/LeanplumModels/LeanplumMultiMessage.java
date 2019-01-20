package Maverick.LeanplumModels;

import java.util.List;

public class LeanplumMultiMessage {

    private String action = "multi";

    public LeanplumMultiMessage() {
        time = System.currentTimeMillis();
    }

    List<LeanplumMessage> data;
    long time;

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public void setTime(long time) {
        this.time = time;
    }

    public List<LeanplumMessage> getData() {
        return data;
    }

    public void setData(List<LeanplumMessage> data) {
        this.data = data;
    }

    public long getTime() {
        return time;
    }

    public void setTime(int time) {
        this.time = time;
    }
}
