package Maverick.MaverickModels;

public class SearchResults {

    SearchResultsResponses responses;

    public SearchResultsResponses getResponses() {
        return responses;
    }

    public void setResponses(SearchResultsResponses responses) {
        this.responses = responses;
    }

    public static class SearchResultsResponses {

        String[] responseIds;

        public String[] getResponseIds() {
            return responseIds;
        }

        public void setResponseIds(String[] responseIds) {
            this.responseIds = responseIds;
        }
    }

}
