public with sharing class PriceBookEntryDAO {
    public PriceBookEntryDAO() {
    }

    public static List<PriceBookEntry> getPriceBookEntries(Set<String> productUUIDSet) {
        String query = 'SELECT Id, Product2Id, Product2.Name, Product2.UnitPrice, Product2.ExternalId FROM PriceBookEntry WHERE Product2.ExternalId IN : productUUIDSet';
        return Database.query(query);
    }
}