public class ConvertLeadsQueueable implements Queueable {

    private List<Lead> leadsToConvert;
    private List<RestResourceDataModels.SiteIncomingData> incomingDataList;

    public ConvertLeadsQueueable(List<Lead> leads, List<RestResourceDataModels.SiteIncomingData> incomingData) {
        leadsToConvert = leads;
        incomingDataList = incomingData;
    }

    public void execute(QueueableContext context) {
        Set<String> uuidSet = extractUuidsFromIncomingData(incomingDataList);
        List<Database.LeadConvert> leadConverts = prepareLeadConverts(leadsToConvert);
        List<Database.LeadConvertResult> convertResults = Database.convertLead(leadConverts);
        Set<String> convertedIds = handleLeadConvertResults(convertResults);

        if (!convertedIds.isEmpty()) {
            List<Lead> convertedLeads = LeadDAO.getConvertedLeadsData(convertedIds);
            List<OpportunityLineItem> oliList = createOpportunityLineItems(convertedLeads, incomingDataList, uuidSet);
            insertOpportunityLineItems(oliList);
        }
    }

    private Set<String> extractUuidsFromIncomingData(List<RestResourceDataModels.SiteIncomingData> incomingDataList) {
        Set<String> uuidSet = new Set<String>();

        for (RestResourceDataModels.SiteIncomingData incomingData : incomingDataList) {
            for (RestResourceDataModels.SiteProductData product : incomingData.products) {
                uuidSet.add(product.uuid.toLowerCase());
            }
        }

        return uuidSet;
    }

    private List<Database.LeadConvert> prepareLeadConverts(List<Lead> leadsToConvert) {
        List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();

        for (Lead ld : leadsToConvert) {
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(ld.Id);
            leadConverts.add(lc);
        }

        return leadConverts;
    }

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

    private void handleLeadConvertErrors(List<Database.Error> errors) {
        for (Database.Error err : errors) {
            System.debug(err.getMessage());
        }
    }

    private List<OpportunityLineItem> createOpportunityLineItems(List<Lead> convertedLeads, 
                                                                List<RestResourceDataModels.SiteIncomingData> incomingDataList, 
                                                                Set<String> uuidSet) {
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

    private OpportunityLineItem createOpportunityLineItem(Id opportunityId, List<PricebookEntry> priceBookEntries, 
                                                        RestResourceDataModels.SiteProductData product) {
        PricebookEntry pricebookEntry = getPricebookEntry(priceBookEntries, product.uuid);
        
        return new OpportunityLineItem(
            OpportunityId = opportunityId,
            PricebookEntryId = pricebookEntry.Id,
            Quantity = product.quantity
        );
    }

    private PricebookEntry getPricebookEntry(List<PricebookEntry> priceBookEntries, String uuid) {
        for (PricebookEntry entry : priceBookEntries) {
            if (entry.Product2.ExternalId.equalsIgnoreCase(uuid)) {
                return entry;
            }
        }
        return null;
    }

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

    private void handleSaveErrors(List<Database.Error> errors) {
        for (Database.Error err : errors) {
            System.debug(err.getMessage());
        }
    }
}
