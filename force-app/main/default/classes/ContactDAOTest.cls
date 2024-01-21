@isTest
private class ContactDAOTest {

    @isTest
    static void testContactCreationAndRetrieval() {
        List<Contact> testContacts = new List<Contact>();
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        for (Integer i = 0; i < 5; i++) {
            testContacts.add(new Contact(
                AccountId = testAccount.Id,
                FirstName = 'Test First Name ' + i,
                LastName = 'Test Last Name ' + i,
                Email = 'test' + i + '@example.com',
                Phone = '555-1234-' + i,
                MailingStreet = 'Test Street ' + i,
                MailingCity = 'Test City ' + i,
                MailingState = 'Test State ' + i,
                MailingPostalCode = 'Test Postal Code ' + i,
                MailingCountry = 'Test Country ' + i
            ));
        }

        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        dml.optAllOrNone = true;

        Test.startTest();
        List<Database.SaveResult> saveResults = ContactDAO.createContacts(testContacts, dml);
        Test.stopTest();

        for (Database.SaveResult saveResult : saveResults) {
            System.assert(saveResult.isSuccess(), 'Contact creation should be successful');
        }

        Set<String> accountNamesSet = new Set<String>{'Test Account'};
        List<Account> accountList = AccountDAO.getAccounts(accountNamesSet);
        List<Contact> retrievedContacts = ContactDAO.getContacts(accountNamesSet);
        System.assertEquals(5, retrievedContacts.size(), 'Unexpected number of contacts retrieved');
        retrievedContacts = ContactDAO.getContactsByAccountIds(new Set<String>{accountList[0].Id});

    }
}
