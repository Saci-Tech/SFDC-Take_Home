@isTest
private class SiteOrdersHandlerTest {
    @TestSetup
    static void makeData(){
        Product2 product = new Product2(
            Name = 'Test Product', 
            ExternalId = 'test uuid', 
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
            FirstName = 'John 2',
            LastName = 'Doe 2',
            Email = 'test2@example.com',
            Phone = '555-1234-2',
            Street = '2 Main St',
            City = 'Cityville',
            State = 'CA',
            PostalCode = '12345',
            Country = 'USA',
            IsConverted = false
        );
        insert testLead;

        Account testAccount = new Account(
            Name = 'Test Company 3',
            AccountNumber = 'ACC 3',
            ExternalId__c = 'Test Company 3',
            AccountSource = 'Web',
            BillingStreet = '3 Main St',
            BillingCity = 'Cityville',
            BillingState = 'CA',
            BillingPostalCode = '12345',
            BillingCountry = 'USA',
            Phone = '555-1234-3',
            ShippingStreet = '3 Main St',
            ShippingCity = 'Cityville',
            ShippingState = 'CA',
            ShippingPostalCode = '12345',
            ShippingCountry = 'USA'
        );
        insert testAccount;

        Contact testContact = new Contact(
            AccountId = testAccount.Id,
            FirstName = 'John 3',
            LastName = 'Doe 3',
            Email = 'test3@example.com',
            Phone = '555-1234-1',
            MailingStreet = '3 Main St',
            MailingCity = 'Cityville',
            MailingState = 'CA',
            MailingPostalCode = '12345',
            MailingCountry = 'USA'
        );
        insert testContact;
    }

    @isTest
    static void testProcessSiteData_Success() {
        List<Account> accList = new List<ACcount>();
        List<RestResourceDataModels.SiteIncomingData> testData = new List<RestResourceDataModels.SiteIncomingData>{
            new RestResourceDataModels.SiteIncomingData(
                'Test Company 1', 
                new List<RestResourceDataModels.SiteProductData>{
                    new RestResourceDataModels.SiteProductData('test uuid', 2)
                },
                new RestResourceDataModels.SiteContactData('John 1', 'Doe 1', 'test1@example.com', '555-1234-1'),
                new RestResourceDataModels.SiteAddressData('1 Main St', 'Cityville', 'CA', '12345', 'USA')
            ),
            new RestResourceDataModels.SiteIncomingData(
                'Test Company 2', 
                new List<RestResourceDataModels.SiteProductData>{
                    new RestResourceDataModels.SiteProductData('test uuid', 2)
                },
                new RestResourceDataModels.SiteContactData('John 2', 'Doe 2', 'test2@example.com', '555-1234-2'),
                new RestResourceDataModels.SiteAddressData('2 Main St', 'Cityville', 'CA', '12345', 'USA')
            ), 
            new RestResourceDataModels.SiteIncomingData(
                'Test Company 3', 
                new List<RestResourceDataModels.SiteProductData>{
                    new RestResourceDataModels.SiteProductData('test uuid', 2)
                },
                new RestResourceDataModels.SiteContactData('John 3', 'Doe 3', 'test3@example.com', '555-1234-3'),
                new RestResourceDataModels.SiteAddressData('3 Main St', 'Cityville', 'CA', '12345', 'USA')
            )
        };

        Test.startTest();
        Boolean result = SiteOrdersHandler.processSiteData(testData);
        Test.stopTest();
        accList = [SELECT Id, Name FROM Account LIMIT 100];
        for(Account acc : accList) {
            System.debug(acc);
        }

        System.assert(result, 'Expected processSiteData to return true');
    }
}