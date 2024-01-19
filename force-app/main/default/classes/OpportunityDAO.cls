public with sharing class OpportunityDAO {
    public static List<Database.SaveResult> createOpportunities(List<Opportunity> opportunityList) {
        return Database.insert(opportunityList, false);
    }

    public static Set<String> getOpportunityIds() {
        Set<String> oppIds = new Set<String>();
        List<Opportunity> opps = [SELECT Id FROM Opportunity];
        for(Opportunity opp: opps) {
            oppIds.add(opp.Id);
        }
        return oppIds;
    }
}