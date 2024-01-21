@RestResource(urlMapping='/siteorders/*')
global with sharing class SiteOrdersRestResource {

    public class SiteOrdersRestResourceException extends Exception {}
    public static Boolean testSwitch = false;

    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String payload = '';
        List<RestResourceDataModels.SiteIncomingData> incomingDataList = new List<RestResourceDataModels.SiteIncomingData>();
        
        try {
            if(test.isRunningTest() && testSwitch) {
                throw new SiteOrdersRestResourceException();
            }
            payload = String.valueOf(req.requestBody.toString());
            if(!String.isEmpty(payload) && !(payload == null)) {
                incomingDataList.add(
                    (RestResourceDataModels.SiteIncomingData) JSON.deserialize(
                        payload, RestResourceDataModels.SiteIncomingData.class
                    )
                );
                if (SiteOrdersHandler.processSiteData(incomingDataList)) {
                    res.statusCode = 200;
                    res.responseBody = Blob.valueOf(JSON.serialize(generateResponseBody(200, 'Record(s) Created Successfully')));
                }
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            System.debug('Cause: ' + e.getCause());
            System.debug('Stack: ' + e.getStackTraceString());
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serializePretty(generateResponseBody(500, 'Internal Server Error')));
        } finally {
            RestContext.response = res;
            System.debug('RestContext.response: ' + RestContext.response);
        }
    }

    public static RestResourceDataModels.ResponseDataModel generateResponseBody(Integer status, String message) {
        return new RestResourceDataModels.ResponseDataModel(status, message);
    }
}