@RestResource(urlMapping='/siteorders/*')
global with sharing class SiteOrdersRestResource {

    @HttpPost
    global static void doPost(String requestBody) {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {

            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serializePretty(generateResponseBody(200, 'Record Created Successfully')));
            RestContext.response = res;
        } catch (Exception e) {
            if (e.getMessage().contains('RecordNotFoundException')) {
                // Handle exceptions or errors - Simulating a 404 error if the record is not found
                res.statusCode = 404;
                res.responseBody = Blob.valueOf(JSON.serializePretty(generateResponseBody(404, 'Record Not Found')));
            } else {
                // Handle exceptions or errors - a generic server error with status 500
                res.statusCode = 500;
                res.responseBody = Blob.valueOf(JSON.serializePretty(generateResponseBody(500, 'Internal Server Error')));
            }

            // Additional error handling - is there any internal facility to hold records/audit trail?

            RestContext.response = res;
        }
    }

    public static RestResourceDataModels.ResponseDataModel generateResponseBody(Integer status, String message) {
        return new RestResourceDataModels.ResponseDataModel(status, message);
    }
}