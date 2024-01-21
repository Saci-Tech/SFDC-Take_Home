public with sharing class AccountDAO {
    public static List<Database.SaveResult> createAccounts(List<Account> accountList, Database.DMLOptions options) {
        try {
            return Database.insert(accountList, options);
        } catch (Exception e) {
            System.debug('Error creating accounts: ' + e.getMessage());
            return new List<Database.SaveResult>();
        }
    }

    public static List<Database.UpsertResult> upsertAccounts(List<Account> accountList) {
        try {
            return Database.upsert(accountList, false);
        } catch (Exception e) {
            System.debug('Error upserting accounts: ' + e.getMessage());
            return new List<Database.UpsertResult>();
        }
    }

    public static List<Account> getAccounts(Set<String> accountNames) {
        List<Account> accounts = new List<Account>();
        
        try {
            String query = 'SELECT Id, Name, ExternalId__c, AccountNumber, AccountSource, BillingAddress, ShippingAddress, Phone FROM Account WHERE Name IN :accountNames';
            accounts = Database.query(query);
        } catch (Exception e) {
            System.debug('Error getting accounts: ' + e.getMessage());
        }

        return accounts;
    }
}
