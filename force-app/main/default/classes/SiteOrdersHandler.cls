public with sharing class SiteOrdersHandler {
    public SiteOrdersHandler() {
        System.debug('New Instance of SiteOrdersHandler');
    }

    public class LeadConversionWrapper {
        public List<Lead> leadsToConvert { get; set; }
        public List<RestResourceDataModels.SiteIncomingData> incomingDataList { get; set; }
    
        public LeadConversionWrapper(List<Lead> leads, List<RestResourceDataModels.SiteIncomingData> incomingData) {
            leadsToConvert = leads;
            incomingDataList = incomingData;
        }
    }

    public static Boolean processSiteData(List<RestResourceDataModels.SiteIncomingData> incomingDataList) {
        Set<String> companyNamesSet = new Set<String>(); // used in the queries
        Set<String> accountsToCreate = new Set<String>(); // used to create the new accounts
        List<Lead> existingLeads = new List<Lead>(); // holds the found lead records using the companyNamesSet
        List<Lead> leadsToConvert = new List<Lead>(); // same, but these have no account/contact/opportunity
        List<Account> existingAccounts = new List<Account>(); // holds the account records found using the companyNamesSet
        List<Account> directAccounts = new List<Account>(); // the found accounts that can have just opportunity + products and maybe contact created

        if(incomingDataList != null && incomingDataList.size() > 0) {
            for(RestResourceDataModels.SiteIncomingData sid : incomingDataList) {
                companyNamesSet.add(sid.companyName); // gets only the companyName property, to use in queries
            }

            // retrieve existing data, if any
            existingLeads = LeadDAO.getLeads(companyNamesSet);
            existingAccounts = AccountDAO.getAccounts(companyNamesSet);

            // iterate and check which lead already has an account - do not convert, 
            // just create the Opportunity and OpportunityLineItems and create/update Contact
            Set<String> tmpNameSet = new Set<String>(); // will allow to separate which accounts/leads exists, from accounts to create
            for(Lead lead : existingLeads) {
                if(!tmpNameSet.contains(lead.Company)) {
                    tmpNameSet.add(lead.Company); 
                }
                Boolean accountFound = false;
                Integer accountIndex = null;
                for(Account account : existingAccounts) {
                    if(!tmpNameSet.contains(account.Name)) {
                        tmpNameSet.add(account.Name); 
                    }
                    if(lead.Company == Account.Name) {
                        accountFound = true;
                        directAccounts.add(account);
                        break;
                    }
                }
                if(!accountFound) {
                    leadsToConvert.add(lead);
                }
            }

            // implement here lead conversion and adding products to opportunity
            System.enqueueJob(new ConvertLeadsQueueable(leadsToConvert, incomingDataList));
        }

        return false;
    }

    public static List<Account> createAccounts(Set<String> toCreateNames, List<RestResourceDataModels.SiteIncomingData> incomingDataList) {
        List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
        return null;
    }

    public static List<Contact> createContacts() {
        return null;
    }

    public static List<Opportunity> createOpportunities() {
        return null;
    }
}