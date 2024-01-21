public class ConvertLeadsQueueable implements Queueable {

    private List<Lead> leadsToConvert;
    private List<RestResourceDataModels.SiteIncomingData> incomingDataList;
    Database.DMLOptions dml = new Database.DMLOptions();

    public ConvertLeadsQueueable(List<Lead> leads, List<RestResourceDataModels.SiteIncomingData> incomingData) {
        leadsToConvert = leads;
        incomingDataList = incomingData;
        dml.DuplicateRuleHeader.AllowSave = true;
        dml.optAllOrNone = true;
    }

    public void execute(QueueableContext context) {
        Set<String> uuidSet = extractUuidsFromIncomingData(incomingDataList);
        List<Database.LeadConvert> leadConverts = prepareLeadConverts(leadsToConvert);
        List<Database.LeadConvertResult> convertResults = Database.convertLead(leadConverts, dml);
        Set<String> convertedIds = handleLeadConvertResults(convertResults);

        if (!convertedIds.isEmpty()) {
            List<Lead> convertedLeads = LeadDAO.getConvertedLeadsData(convertedIds);
            List<OpportunityLineItem> oliList = createOpportunityLineItems(convertedLeads, incomingDataList, uuidSet);
            insertOpportunityLineItems(oliList);
        }
    }

    @testVisible
    private Set<String> extractUuidsFromIncomingData(List<RestResourceDataModels.SiteIncomingData> incomingDataList) {
        Set<String> uuidSet = new Set<String>();

        for (RestResourceDataModels.SiteIncomingData incomingData : incomingDataList) {
            for (RestResourceDataModels.SiteProductData product : incomingData.products) {
                uuidSet.add(product.uuid.toLowerCase());
            }
        }

        return uuidSet;
    }

    @testVisible
    private List<Database.LeadConvert> prepareLeadConverts(List<Lead> leadsToConvert) {
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
        Set<String> leadIdsSet = new Set<String>();
        List<Lead> uniqueLeadsToConvert = new List<Lead>();
        
        for (Lead lead : leadsToConvert) {
            if (!leadIdsSet.contains(lead.Id)) {
                leadIdsSet.add(lead.Id);
                uniqueLeadsToConvert.add(lead);
            }
        }

        for (Lead ld : uniqueLeadsToConvert) {
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(ld.Id);
            lc.setConvertedStatus(convertStatus.MasterLabel);
            leadConverts.add(lc);
        }

        return leadConverts;
    }

    @testVisible
    private Set<String> handleLeadConvertResults(List<Database.LeadConvertResult> convertResults) {
        Set<String> convertedIds = new Set<String>();

        for (Database.LeadConvertResult convertResult : convertResults) {
            if (convertResult.isSuccess()) {
                convertedIds.add(convertResult.getLeadId());
            } else {
                handleLeadConvertErrors(convertResult.errors);
            }
        }

        return convertedIds;
    }

    @testVisible
    private void handleLeadConvertErrors(List<Database.Error> errors) {
        for (Database.Error err : errors) {
            System.debug(err.getMessage());
        }
    }

    @testVisible
    private List<OpportunityLineItem> createOpportunityLineItems(List<Lead> convertedLeads, List<RestResourceDataModels.SiteIncomingData> incomingDataList, Set<String> uuidSet) {
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        List<PricebookEntry> priceBookEntries = PriceBookEntryDAO.getPriceBookEntries(uuidSet);

        for (Lead ld : convertedLeads) {
            for (RestResourceDataModels.SiteIncomingData incoming : incomingDataList) {
                if (incoming.companyName == ld.Company) {
                    for (RestResourceDataModels.SiteProductData product : incoming.products) {
                        oliList.add(createOpportunityLineItem(ld.ConvertedOpportunityId, priceBookEntries, product));
                    }
                }
            }
        }

        return oliList;
    }

    @testVisible
    private OpportunityLineItem createOpportunityLineItem(Id opportunityId, List<PricebookEntry> priceBookEntries, 
                                                        RestResourceDataModels.SiteProductData product) {
        PricebookEntry pricebookEntry = getPricebookEntry(priceBookEntries, product.uuid);
        
        return new OpportunityLineItem(
            OpportunityId = opportunityId,
            PricebookEntryId = pricebookEntry.Id,
            Quantity = product.quantity,
            UnitPrice = pricebookEntry.UnitPrice
        );
    }

    @testVisible
    private PricebookEntry getPricebookEntry(List<PricebookEntry> priceBookEntries, String uuid) {
        for (PricebookEntry entry : priceBookEntries) {
            if (entry.Product2.ExternalId.equalsIgnoreCase(uuid)) {
                return entry;
            }
        }
        return null;
    }

    @testVisible
    private void insertOpportunityLineItems(List<OpportunityLineItem> oliList) {
        if (!oliList.isEmpty()) {
            List<Database.SaveResult> saveResults = Database.insert(oliList, false);

            for (Database.SaveResult saveResult : saveResults) {
                if (!saveResult.isSuccess()) {
                    handleSaveErrors(saveResult.getErrors());
                }
            }
        }
    }

    @testVisible
    private void handleSaveErrors(List<Database.Error> errors) {
        for (Database.Error err : errors) {
            System.debug(err.getMessage());
        }
    }
}
