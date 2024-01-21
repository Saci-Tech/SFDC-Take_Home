@isTest
private class SiteOrdersRestResourceTest {
    @TestSetup
    static void makeData(){
        String uuid = 'test uuid';
        Product2 product = new Product2(
            Name = 'Test Product', 
            ExternalId = uuid, 
            IsActive = true
        );
        insert product;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = test.getStandardPricebookId(),
            Product2Id = product.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

        Lead testLead = new Lead(
            Company = 'Test Company 2',
            FirstName = 'Test First Name',
            LastName = 'Test Last Name ',
            Email = 'test@example.com',
            Phone = '555-1234-1'
        );
        insert testLead;

        Account testAccount = new Account(
            Name = 'Test Account 3',
            AccountNumber = 'ACC',
            AccountSource = 'Web',
            BillingStreet = 'Billing Street ',
            BillingCity = 'Billing City ',
            BillingState = 'Billing State ',
            BillingPostalCode = '12345',
            BillingCountry = 'United States',
            ShippingStreet = 'Shipping Street ',
            ShippingCity = 'Shipping City ',
            ShippingState = 'Shipping State ',
            ShippingPostalCode = '54321',
            ShippingCountry = 'United States',
            Phone = '555-1234-1'
        );
        insert testAccount;
        Contact testContact = new Contact(
            AccountId = testAccount.Id,
            FirstName = 'Test First Name',
            LastName = 'Test Last Name',
            Email = 'test3@example.com',
            Phone = '555-1234-1',
            MailingStreet = 'Test Street',
            MailingCity = 'Test City',
            MailingState = 'Test State',
            MailingPostalCode = 'Test Postal Code',
            MailingCountry = 'Test Country'
        );
        insert TestContact;
    }

    @isTest
    static void testDoPost_Success() {
        RestResourceDataModels.SiteIncomingData testData = new RestResourceDataModels.SiteIncomingData(
            'Test Company', 
            new List<RestResourceDataModels.SiteProductData>{
                new RestResourceDataModels.SiteProductData('test uuid', 2)
            },
            new RestResourceDataModels.SiteContactData('John', 'Doe', 'john.doe@example.com', '123-456-7890'),
            new RestResourceDataModels.SiteAddressData('123 Main St', 'Cityville', 'CA', '12345', 'USA')
        );
        System.debug('testData: ' + testData);

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        String requestBody = JSON.serializePretty(testData, true);
        request.requestURI = '/services/apexrest/siteorders/';
        request.httpMethod = 'POST';    
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf(requestBody);
        System.debug('request: ' + request);

        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        SiteOrdersRestResource.doPost();
        Test.stopTest();

        System.debug('response: ' + response);

        System.assertNotEquals(null, response.responseBody, 'Response body should not be null');

        if (response.responseBody != null) {
            RestResourceDataModels.ResponseDataModel result = 
                (RestResourceDataModels.ResponseDataModel)JSON.deserialize(
                    response.responseBody.toString(), RestResourceDataModels.ResponseDataModel.class
                );

            System.assertEquals(200, response.statusCode, 'Expected status code 200');
            System.assertEquals('Record(s) Created Successfully', result.message, 'Unexpected response message');
        }
    }

    @isTest
    static void testDoPost_Exception() {
        RestResourceDataModels.SiteIncomingData testData = new RestResourceDataModels.SiteIncomingData(
            'Test Company', 
            new List<RestResourceDataModels.SiteProductData>{
                new RestResourceDataModels.SiteProductData('test uuid', 2)
            },
            new RestResourceDataModels.SiteContactData('John', 'Doe', 'john.doe@example.com', '123-456-7890'),
            new RestResourceDataModels.SiteAddressData('123 Main St', 'Cityville', 'CA', '12345', 'USA')
        );
        System.debug('testData: ' + testData);

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        String requestBody = JSON.serializePretty(testData, true);
        request.requestURI = '/services/apexrest/siteorders/';
        request.httpMethod = 'POST';    
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf(requestBody);
        System.debug('request: ' + request);

        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        SiteOrdersRestResource.testSwitch = true;
        SiteOrdersRestResource.doPost();
        Test.stopTest();

        System.debug('response: ' + response.responseBody.toString());

        System.assertNotEquals(null, response.responseBody, 'Response body should not be null');

        if (response.responseBody != null) {
            RestResourceDataModels.ResponseDataModel result = 
                (RestResourceDataModels.ResponseDataModel)JSON.deserialize(
                    response.responseBody.toString(), RestResourceDataModels.ResponseDataModel.class
                );

            System.assertEquals(500, response.statusCode, 'Expected status code 500');
            System.assertEquals('Internal Server Error', result.message, 'Unexpected response message');
        }
    }
}
