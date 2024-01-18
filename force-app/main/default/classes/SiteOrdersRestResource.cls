@RestResource(urlMapping='/siteorders/*')
global with sharing class SiteOrdersRestResource {
    
    @HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {

            res.statusCode = 200;
            res.responseBody = Blob.valueOf('Created');
            RestContext.response = res;
        } catch (Exception e) {
            // Handle exceptions or errors
            // Simulating a 404 error if the record is not found
            if (e.getMessage().contains('RecordNotFoundException')) {
                res.statusCode = 404;
                res.responseBody = Blob.valueOf('Record not found');
            } else {
                // Simulating a generic server error with status 500
                res.statusCode = 500;
                res.responseBody = Blob.valueOf('Internal Server Error');
            }
            RestContext.response = res;
        }
    }

    @HttpPost
    global static void doPost(String requestBody) {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {

            res.statusCode = 200;
            res.responseBody = Blob.valueOf('Created');
            RestContext.response = res;
        } catch (Exception e) {
            // Handle exceptions or errors
            // Simulating a 404 error if the record is not found
            if (e.getMessage().contains('RecordNotFoundException')) {
                res.statusCode = 404;
                res.responseBody = Blob.valueOf('Record not found');
            } else {
                // Simulating a generic server error with status 500
                res.statusCode = 500;
                res.responseBody = Blob.valueOf('Internal Server Error');
            }
            RestContext.response = res;
        }
    }
}