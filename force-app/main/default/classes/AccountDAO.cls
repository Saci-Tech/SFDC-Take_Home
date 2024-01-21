public with sharing class AccountDAO {
    public static List<Database.SaveResult> createAccounts(List<Account> accountList, Database.DMLOptions options) {
        return Database.insert(accountList, options);
    }

    public static List<Database.UpsertResult> upsertAccounts(List<Account> accountList) {
        return Database.upsert(accountList, false);
    }

    public static List<Account> getAccounts(Set<String> accountNames) {
        String query = 'SELECT Id, Name, ExternalId__c, AccountNumber, AccountSource, BillingAddress, ShippingAddress, Phone FROM Account WHERE Name IN :accountNames';
        return Database.query(query);
    }
}
