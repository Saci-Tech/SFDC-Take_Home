public with sharing class PriceBookEntryDAO {
    public static List<Database.SaveResult> createOpportunityLineItems(List<OpportunityLineItem> oppLineItemList) {
        return Database.insert(oppLineItemList, false);
    }

    public static List<PriceBookEntry> getPriceBookEntries(Set<String> productUUIDSet) {
        String query = 'SELECT Id, Product2Id, Product2.Name, UnitPrice, Product2.ExternalId FROM PriceBookEntry WHERE Product2.ExternalId IN : productUUIDSet';
        return Database.query(query);
    }
}