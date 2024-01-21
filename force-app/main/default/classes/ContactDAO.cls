public with sharing class ContactDAO {
    public static List<Database.SaveResult> createContacts(List<Contact> contactList, Database.DMLOptions options) {
        return Database.insert(contactList, options);
    }

    public static List<Contact> getContacts(Set<String> accountNames) {
        String query = 'SELECT Id, AccountId, Account.Name, Email, Phone, MailingAddress FROM Contact WHERE Account.Name IN : accountNames';
        return Database.query(query);
    }

    public static List<Contact> getContactsByAccountIds(Set<String> accountIds) {
        String query = 'SELECT Id, AccountId, Account.Name, Email, Phone, MailingAddress FROM Contact WHERE AccountId IN : accountIds';
        return Database.query(query);
    }
    
}