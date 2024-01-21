@isTest
public class OpportunityLineItemDAOTest {

    @isTest
    static void testCreateOpportunityLineItems() {
        List<Database.SaveResult> result = new List<Database.SaveResult>();

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity', 
            CloseDate = Date.today(), 
            StageName = 'Prospecting', 
            Amount = 1000, 
            AccountId = createTestAccount().Id);
        insert opp;

        PricebookEntry standardPbEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = createTestProduct().Id,
            UnitPrice = 500,
            IsActive = true
        );
        insert standardPbEntry;

        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            PricebookEntryId = standardPbEntry.Id,
            Quantity = 2,
            UnitPrice = standardPbEntry.UnitPrice
        );

        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>{ oli };

        Test.startTest();
        result = OpportunityLineItemDAO.createOpportunityLineItems(oliList);
        Test.stopTest();
        for(Database.SaveResult res : result) {
            if(!res.isSuccess()) {
                for(Database.Error err : res.errors) {
                    System.debug(err.getMessage());
                }
            }
        }

        System.assertEquals(1, result.size());
        System.assert(result[0].isSuccess());
    }

    @isTest
    static void testGetOpportunityLineItemsByOpportunityIds() {
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity', 
            CloseDate = Date.today(), 
            StageName = 'Prospecting', 
            Amount = 1000, 
            AccountId = createTestAccount().Id
        );
        insert opp;

        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = createTestProduct().Id,
            UnitPrice = 500,
            IsActive = true
        );
        insert pbEntry;

        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            PricebookEntryId = pbEntry.Id,
            Quantity = 2,
            UnitPrice = pbEntry.UnitPrice
        );
        insert oli;

        Set<String> opportunityIdSet = new Set<String>{ opp.Id };

        Test.startTest();
        List<OpportunityLineItem> result = OpportunityLineItemDAO.getOpportunityLineItemsByOpportunityIds(opportunityIdSet);
        Test.stopTest();

        System.assertEquals(1, result.size());
        System.assertEquals(opp.Id, result[0].OpportunityId);
    }

    @isTest
    static void testGetOpportunityLineItemsByIds() {

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity', 
            CloseDate = Date.today(), 
            StageName = 'Prospecting', 
            Amount = 1000, 
            AccountId = createTestAccount().Id
        );
        insert opp;

        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = createTestProduct().Id,
            UnitPrice = 500,
            IsActive = true
        );
        insert pbEntry;

        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            PricebookEntryId = pbEntry.Id,
            Quantity = 2,
            TotalPrice = 2 * pbEntry.UnitPrice
        );
        insert oli;

        Set<String> opportunityLineItemIdSet = new Set<String>{ oli.Id };

        Test.startTest();
        List<OpportunityLineItem> result = OpportunityLineItemDAO.getOpportunityLineItemsByIds(opportunityLineItemIdSet);
        Test.stopTest();

        System.assertEquals(1, result.size());
        System.assertEquals(oli.Id, result[0].Id);
    }

    private static Account createTestAccount() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        return acc;
    }

    private static Product2 createTestProduct() {
        Product2 prod = new Product2(Name = 'Test Product', IsActive = true);
        insert prod;
        return prod;
    }
}
