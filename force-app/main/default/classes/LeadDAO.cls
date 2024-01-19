public with sharing class LeadDAO {
    public LeadDAO() {}

    public static List<Database.SaveResult> createLeads(List<Lead> leadList) {
        return Database.insert(leadList, false);
    }

    public static List<Lead> getLeads(Set<String> companyNamesSet) {
        String query = 'SELECT Id, Address, Name, Company, Email, Phone, Status, LeadSource, OwnerId FROM Lead WHERE Company IN : companyNamesSet OR Name IN : companyNamesSet AND IsConverted = false';
        return Database.query(query);
    }

    public static List<Lead> getConvertedLeadsData(Set<String> leadIdsSet) {
        return [SELECT Id, Company, ConvertedOpportunityId, ConvertedAccountId, ConvertedContactId FROM Lead WHERE Id IN : leadIdsSet];
    }
}