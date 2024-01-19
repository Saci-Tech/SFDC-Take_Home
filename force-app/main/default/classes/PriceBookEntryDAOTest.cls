@isTest
private class PriceBookEntryDAOTest {

    @isTest
    static void testPriceBookEntryDAO() {
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

        Opportunity opp = new Opportunity(
            Name = 'Test ' + Date.today(),
            CloseDate = Date.today().addDays(7),
            StageName = 'Prospecting',
            Type = 'New Customer'
        );
        insert opp;

        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>{
            new OpportunityLineItem(
                PricebookEntryId = pbe.Id,
                OpportunityId = opp.Id,
                Quantity = 10,
                UnitPrice = pbe.UnitPrice
            )
        };

        List<Database.SaveResult> saveResults = PriceBookEntryDAO.createOpportunityLineItems(oppLineItemList);
        for (Database.SaveResult saveResult : saveResults) {
            System.assert(saveResult.isSuccess(), 'OpportunityLineItem creation failed: ' + saveResult.getErrors());
        }

        Set<String> productUUIDSet = new Set<String>{uuid};
        List<PriceBookEntry> priceBookEntries = PriceBookEntryDAO.getPriceBookEntries(productUUIDSet);

        System.assert(priceBookEntries.size() > 0, 'Unexpected number of PriceBookEntries returned');
    }
}