public with sharing class AccountDAO {
    public AccountDAO() {}

    public static List<Database.SaveResult> createAccounts(List<Account> accountList) {
        return Database.insert(accountList, false);
    }

    public static List<Account> getAccounts(Set<String> accountNames) {
        String query = 'SELECT Id, Name, AccountNumber, AccountSource, BillingAddress, ShippingAddress, Phone FROM Account WHERE Name IN : accountNames';
        return Database.query(query);
    }
}