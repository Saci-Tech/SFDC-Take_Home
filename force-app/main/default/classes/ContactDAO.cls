public with sharing class ContactDAO {
    public ContactDAO() {}

    public static List<Database.SaveResult> createContacts(List<Contact> contactList) {
        return Database.insert(contactList, false);
    }

    public static List<Contact> getContacts(Set<String> accountNames) {
        String query = 'SELECT Id, AccountId, Account.Name, Email, Phone, MailingAddress FROM Contact WHERE Account.Name IN : accountNames';
        return Database.query(query);
    }
    
}