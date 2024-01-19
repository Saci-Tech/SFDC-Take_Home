public with sharing class OpportunityLineItemDAO {
    public static List<Database.SaveResult> createOpportunityLineItems(List<OpportunityLineItem> opportunityLineItemsList) {
        return Database.insert(opportunityLineItemsList, false);
    }
    
    public static List<OpportunityLineItem> getOpportunityLineItemsByOpportunityIds(Set<String> opportunityIdSet) {
        String query = 'SELECT Id, OpportunityId, PricebookEntryId, Quantity FROM OpportunityLineItem WHERE OpportunityId IN : opportunityIdSet';
        return Database.query(query);
    }

    public static List<OpportunityLineItem> getOpportunityLineItemsByIds(Set<String> opportunityLineItemIdSet) {
        String query = 'SELECT Id, OpportunityId, PricebookEntryId, Quantity FROM OpportunityLineItem WHERE Id IN : opportunityLineItemIdSet';
        return Database.query(query);
    }
}