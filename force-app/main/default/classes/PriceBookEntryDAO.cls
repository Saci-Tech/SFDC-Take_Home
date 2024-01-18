public with sharing class PriceBookEntryDAO {
    public PriceBookEntryDAO() {
    }

    public static List<PriceBookEntry> getPriceBookEntries(Set<String> uuidSet) {
        String query = 'SELECT Id, Product2.Id, Product2.Name, Product2.UnitPrice, Product2.ExternalId FROM PriceBookEntry WHERE Product2.ExternalId IN uuidSet';
        return Database.query(query);
    }
}