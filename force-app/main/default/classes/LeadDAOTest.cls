@isTest
private class LeadDAOTest {

    @isTest
    static void testLeadCreationAndRetrieval() {
        List<Lead> testLeads = new List<Lead>();
        for (Integer i = 0; i < 5; i++) {
            testLeads.add(new Lead(
                Company = 'Test Company ' + i,
                FirstName = 'Test First Name ' + i,
                LastName = 'Test Last Name ' + i,
                Email = 'test' + i + '@example.com',
                Phone = '555-1234-' + i
            ));
        }

        Test.startTest();
        List<Database.SaveResult> saveResults = LeadDAO.createLeads(testLeads);
        Test.stopTest();

        for (Database.SaveResult saveResult : saveResults) {
            System.assert(saveResult.isSuccess(), 'Lead creation should be successful');
        }

        Set<String> companyNamesSet = new Set<String>();
        for (Integer i = 0; i < 5; i++) {
            companyNamesSet.add('Test Company ' + i);
        }

        List<Lead> retrievedLeads = LeadDAO.getLeads(companyNamesSet);
        System.assertEquals(5, retrievedLeads.size(), 'Unexpected number of leads retrieved');

    }

    @isTest
    static void testConvertedLeadsRetrieval() {
        List<Lead> convertedLeads = [SELECT Id FROM Lead WHERE IsConverted = true LIMIT 5];
        Set<String> leadIdsSet = new Set<String>();

        for (Lead convertedLead : convertedLeads) {
            leadIdsSet.add(convertedLead.Id);
        }

        List<Lead> retrievedConvertedLeads = LeadDAO.getConvertedLeadsData(leadIdsSet);
        System.assertEquals(convertedLeads.size(), retrievedConvertedLeads.size(), 'Unexpected number of converted leads retrieved');
    }
}
