@isTest
private class OpportunityDAOTest {

    @isTest
    static void testOpportunityDAO() {
        List<Opportunity> opportunityList = new List<Opportunity>{
            new Opportunity(
                Name = 'Test ' + Date.today(),
                CloseDate = Date.today(), 
                StageName = 'Prospecting', 
                Amount = 1000
            )
        };

        List<Database.SaveResult> saveResults = OpportunityDAO.createOpportunities(opportunityList);

        for (Database.SaveResult saveResult : saveResults) {
            System.assert(saveResult.isSuccess(), 'Opportunity creation failed: ' + saveResult.getErrors());
        }

        Set<String> opportunityIds = OpportunityDAO.getOpportunityIds();

        System.assertEquals(opportunityList.size(), opportunityIds.size(), 'Unexpected number of OpportunityIds returned');
    }
}
