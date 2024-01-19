@isTest
private class AccountDAOTest {

    @isTest
    static void testAccountCreationAndRetrieval() {
        List<Account> testAccounts = new List<Account>();
        for (Integer i = 0; i < 3; i++) {
            testAccounts.add(new Account(
                Name = 'Test Account ' + i,
                AccountNumber = 'ACC' + i,
                AccountSource = 'Web',
                BillingStreet = 'Billing Street ' + i,
                BillingCity = 'Billing City ' + i,
                BillingState = 'Billing State ' + i,
                BillingPostalCode = '12345',
                BillingCountry = 'United States',
                ShippingStreet = 'Shipping Street ' + i,
                ShippingCity = 'Shipping City ' + i,
                ShippingState = 'Shipping State ' + i,
                ShippingPostalCode = '54321',
                ShippingCountry = 'United States',
                Phone = '555-1234-' + i
            ));
        }

        Test.startTest();
        List<Database.SaveResult> saveResults = AccountDAO.createAccounts(testAccounts);
        Test.stopTest();

        for (Database.SaveResult saveResult : saveResults) {
            System.assert(saveResult.isSuccess(), 'Account creation should be successful');
        }

        Set<String> accountNamesSet = new Set<String>{'Test Account 0', 'Test Account 1', 'Test Account 2'};
        List<Account> retrievedAccounts = AccountDAO.getAccounts(accountNamesSet);

        System.assertEquals(3, retrievedAccounts.size(), 'Unexpected number of accounts retrieved');
    }
}
