@isTest
private class ConvertLeadsQueueableTest {

    @testSetup
    static void setupTestData() {
        Set<String> leadIds = new Set<String>();
        List<Lead> leadsToInsert = new List<Lead>();
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
        List<Database.LeadConvertResult> convertResults = new List<Database.LeadConvertResult>();
        List<Product2> products = new List<Product2>();
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        List<RestResourceDataModels.SiteIncomingData> incomingDataList = new List<RestResourceDataModels.SiteIncomingData>();
        
        for(Integer i = 0;i < 4;i++) {
            // Create sample leads
            leadsToInsert.add(new Lead(FirstName = 'John', LastName = 'Doe', Company = 'Test Company ' + (i + 1), Email = 'testlead0' + (i + 1) + '@test.com', Phone = (i + 1) + ' 123 456 78'));
        }
        List<Database.SaveResult> results = LeadDAO.createLeads(leadsToInsert);
        for(Database.SaveResult result : results) {
            if(Math.mod(results.indexOf(result), 2) == 0) {
                leadIds.add(result.getId());
            }
        }
        for(String s : leadIds) {
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(s);
            lc.setConvertedStatus(convertStatus.MasterLabel);
            leadConverts.add(lc);
        }
        convertResults = Database.convertLead(leadConverts, false);

        for(Integer i = 0;i < 4;i++) {
            incomingDataList.add(new RestResourceDataModels.SiteIncomingData(
                'Test Company ' + (i + 1), 
                new List<RestResourceDataModels.SiteProductData>{
                    new RestResourceDataModels.SiteProductData('Teste' + (i + 1), 2)
                }, 
                new RestResourceDataModels.SiteContactData('John', 'Doe', 'testlead0' + (i + 1) + '@test.com', (i + 1) + ' 123 456 78'), 
                new RestResourceDataModels.SiteAddressData('Street ' + (i + 1), 'City ' + (i + 1), 'Test', null, 'Brazil')
            ));
            products.add(new Product2(
                Name = 'Teste ' + (i + 1),
                ExternalId = 'teste ' + (i + 1)
            ));
        } 
        insert products;
        for(Product2 product : products) {
            pricebookEntries.add(
                new PricebookEntry(
                    Pricebook2Id = test.getStandardPricebookId(),
                    Product2Id = product.Id,
                    UnitPrice = 100,
                    IsActive = true
                )
            );
        }

        insert pricebookEntries;

    }

    @isTest
    static void testConvertLeadsQueueable() {
        Set<String> namesList = new Set<String>();
        List<RestResourceDataModels.SiteIncomingData> incomingDataList = new List<RestResourceDataModels.SiteIncomingData>();
        List<Lead> leadsToConvert = new List<Lead>();
        List<Opportunity> oppotunityList = new List<Opportunity>();
        // Create sample incomingData
        for(Integer i = 0;i < 4;i++) {
            incomingDataList.add(new RestResourceDataModels.SiteIncomingData(
                'Test Company ' + (i + 1), 
                new List<RestResourceDataModels.SiteProductData>{
                    new RestResourceDataModels.SiteProductData('Teste ' + (i + 1), 2)
                }, 
                new RestResourceDataModels.SiteContactData('John', 'Doe', 'testlead0' + (i + 1) + '@test.com', (i + 1) + ' 123 456 78'), 
                new RestResourceDataModels.SiteAddressData('Street ' + (i + 1), 'City ' + (i + 1), 'Test', null, 'Brazil')
            ));
        }

        for(RestResourceDataModels.SiteIncomingData incoming : incomingDataList) {
            namesList.add(incoming.companyName);
        }

        leadsToConvert = LeadDAO.getLeads(namesList);
        test.startTest();
        System.enqueueJob(new ConvertLeadsQueueable(leadsToConvert, incomingDataList));
        test.stopTest();

        List<OpportunityLineItem> oliList = OpportunityLineItemDAO.getOpportunityLineItemsByOpportunityIds(OpportunityDAO.getOpportunityIds());

        System.assert(oliList.size() > 0, 'oliList has no records.');
    }
}