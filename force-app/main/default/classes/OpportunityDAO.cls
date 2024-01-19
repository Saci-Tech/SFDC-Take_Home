public with sharing class OpportunityDAO {
    public OpportunityDAO() {}

    public static List<Database.SaveResult> createOpportunities(List<Opportunity> opportunityList) {
        return Database.insert(opportunityList, false);
    }
    
}