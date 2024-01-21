public with sharing class SiteOrdersHandler {

    public static List<Account> existingAccounts = new List<Account>();
    public static List<PriceBookEntry> pricebookEntries = new List<PriceBookEntry>();
    public static List<Contact> existingContacts = new List<Contact>();
    public static List<Contact> contactsToCreate = new List<Contact>();
    public static List<Lead> leadsToConvert = new List<Lead>();
    public static List<RestResourceDataModels.SiteIncomingData> incomingDataList = new List<RestResourceDataModels.SiteIncomingData>();

    public class SiteOrdersHandlerException extends Exception {}

    public static Boolean processSiteData(List<RestResourceDataModels.SiteIncomingData> x_incomingDataList) {
        incomingDataList = x_incomingDataList;
        Set<String> companyNamesSet = new Set<String>();
        Set<String> accountsToCreate = new Set<String>();
        Set<String> tmpNameSet = new Set<String>();
        List<Lead> existingLeads = new List<Lead>();
        Integer errorCount = 0;

        try {
            if(incomingDataList != null && incomingDataList.size() > 0) {
                for(RestResourceDataModels.SiteIncomingData sid : incomingDataList) {
                    companyNamesSet.add(sid.companyName);
                }
    
                existingLeads = LeadDAO.getLeads(companyNamesSet);
                existingAccounts = AccountDAO.getAccounts(companyNamesSet);
    
                for(Lead lead : existingLeads) {
                    if(!tmpNameSet.contains(lead.Company)) {
                        tmpNameSet.add(lead.Company); 
                    }
                    if(existingAccounts != null && existingAccounts.size() > 0) {
                        Boolean accountFound = false;
                        Integer accountIndex = null;
                        for(Account account : existingAccounts) {
                            if(!tmpNameSet.contains(account.Name)) {
                                tmpNameSet.add(account.Name); 
                            }
                            if(lead.Company == account.Name) {
                                accountFound = true;
                                break;
                            }
                        }
                        if(!accountFound) {
                            leadsToConvert.add(lead);
                        }
                    }
                }
    
                for(String name : companyNamesSet) { 
                    if(!tmpNameSet.contains(name)) { 
                        accountsToCreate.add(name);
                    }
                }

                errorCount = createRecords(accountsToCreate, incomingDataList);
                System.enqueueJob(new ConvertLeadsQueueable(leadsToConvert, incomingDataList));

            }
        } catch (Exception ex) {
            System.debug('Message: ' + ex.getMessage());
            System.debug('Cause: ' + ex.getCause());
            System.debug('Stack: ' + ex.getStackTraceString());
        }
        return (errorCount == 0);
    }

    public static Integer createRecords(Set<String> toCreateNames, List<RestResourceDataModels.SiteIncomingData> incomingDataList) {
        Set<String> productsUUID = new Set<String>();
        Set<String> existingAccIdSet = new Set<String>();
        List<Account> accountsToCreate = new List<Account>();
        List<Opportunity> opportunitiesToCreate = new List<Opportunity>();
        List<OpportunityLineItem> oliToCreate = new List<OpportunityLineItem>();
        List<Database.SaveResult> saveAccounts = new List<Database.SaveResult>();
        List<Database.SaveResult> saveContacts = new List<Database.SaveResult>();
        List<Database.SaveResult> saveOpportunities = new List<Database.SaveResult>();
        List<Database.SaveResult> saveOlis = new List<Database.SaveResult>();
        Integer errorCount = 0;

        for(String name : toCreateNames) {
            for(RestResourceDataModels.SiteIncomingData incomingData : incomingDataList) {
                if(name == incomingData.companyName) {
                    accountsToCreate.add(
                        createAccountInstance(incomingData)
                    );
                    
                    for(RestResourceDataModels.SiteProductData product : incomingData.products) {
                        productsUUID.add(product.uuid);
                    }
                }
            }
        }
        if(existingAccounts != null && existingAccounts.size() > 0) {
            for(Account acc : existingAccounts) {
                for(Account toCreate: accountsToCreate) {
                    if(acc.Name == toCreate.Name) {
                        toCreate.Id = acc.Id;
                    }
                }
            }
        }

        pricebookEntries = PriceBookEntryDAO.getPriceBookEntries(productsUUID);
        System.debug('pricebookEntries: ' + pricebookEntries);

        for(Account acc : accountsToCreate) {
            System.debug('accountsToCreate: ' + acc);
        }

        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        dml.optAllOrNone = true;
        saveAccounts = AccountDAO.createAccounts(accountsToCreate, dml);
        for(Database.SaveResult result : saveAccounts) {
            if(result.isSuccess()) {
                for(RestResourceDataModels.SiteIncomingData incomingData : incomingDataList) {
                    if(accountsToCreate[saveAccounts.indexOf(result)].Name == incomingData.companyName) {
                        contactsToCreate.add(
                            createContactInstance(result.getId(), incomingData.contact, incomingData.address)
                        );
                        break;
                    }
                }
            } else {
                errorCount++;
                for(Database.Error err : result.getErrors()) {
                    System.debug('Erro ao criar Conta: ' + err.getMessage());
                }
            }
        }

        saveContacts = ContactDAO.createContacts(contactsToCreate, dml);
        for(Database.SaveResult result : saveContacts) {
            if(result.isSuccess()) {
                for(Account acc: accountsToCreate) {
                    if(acc.Id == contactsToCreate[saveContacts.indexOf(result)].AccountId) {
                        opportunitiesToCreate.add(
                            createOpportunityInstance(acc.Id, acc.Name, result.getId())
                        );
                    }
                }
            } else {
                errorCount++;
                for(Database.Error err : result.getErrors()) {
                    System.debug('Erro ao criar Contato: ' + err.getMessage());
                }
            }
        }
        if(existingAccounts != null && existingAccounts.size() > 0) {
            accountsToCreate.addAll(existingAccounts); 
            for(Account acc : existingAccounts) {
                existingAccIdSet.add(acc.Id);
            }
            existingContacts = ContactDAO.getContactsByAccountIds(existingAccIdSet);
            contactsToCreate.addAll(existingContacts);
            for(Account acc : existingAccounts) {
                for(Contact ctt : existingContacts) {
                    if(acc.Id == ctt.AccountId) {
                        opportunitiesToCreate.add(createOpportunityInstance(acc.Id, acc.Name, ctt.Id));
                    }
                }
            }
        }

        saveOpportunities = OpportunityDAO.createOpportunities(opportunitiesToCreate);
        for(Database.SaveResult result : saveOpportunities) {
            if(result.isSuccess()) {
                for(Account acc : accountsToCreate) {
                    
                    if(acc.Id == opportunitiesToCreate[saveOpportunities.indexOf(result)].AccountId) {

                        for(RestResourceDataModels.SiteIncomingData incomingData : incomingDataList) {

                            if(acc.Name == incomingData.companyName) {

                                for(PricebookEntry pbe : pricebookEntries) {

                                    for(RestResourceDataModels.SiteProductData product : incomingData.products) {

                                        if(pbe.Product2.ExternalId == product.uuid) {
                                            oliToCreate.add(
                                                createOpportunityLineItemInstance(result.getId(), pbe, product)
                                            );
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                errorCount++;
                for(Database.Error err : result.getErrors()) {
                    System.debug(err.getMessage());
                }
            }
        }
        System.debug('opportunitiesToCreate.size(): ' + opportunitiesToCreate.size());

        saveOlis = PriceBookEntryDAO.createOpportunityLineItems(oliToCreate);
        for(Database.SaveResult result : saveOlis) {
            if(!result.isSuccess()) {
                errorCount++;
                for(Database.Error err : result.getErrors()) {
                    System.debug(err.getMessage());
                }
            }
        }
        System.debug('accountsToCreate: ' + accountsToCreate.size());
        System.debug('contactsToCreate: ' + contactsToCreate.size());
        System.debug('opportunitiesToCreate: ' + opportunitiesToCreate.size());
        System.debug('oliToCreate: ' + oliToCreate.size());
        
        return errorCount;
    }

    public static Account createAccountInstance(RestResourceDataModels.SiteIncomingData incomingData) {
        return new Account(
            Name = incomingData.companyName,
            AccountSource = 'Web',
            ExternalId__c = incomingData.companyName,
            BillingStreet = incomingData.address.street,
            BillingCity = incomingData.address.city,
            BillingState = incomingData.address.state,
            BillingPostalCode = incomingData.address.postalCode,
            BillingCountry = incomingData.address.country,
            ShippingStreet = incomingData.address.street,
            ShippingCity = incomingData.address.city,
            ShippingState = incomingData.address.state,
            ShippingPostalCode = incomingData.address.postalCode,
            ShippingCountry = incomingData.address.country,
            Phone = incomingData.contact.phone
        );
    }

    public static Contact createContactInstance(String accountId, RestResourceDataModels.SiteContactData contactData, RestResourceDataModels.SiteAddressData addressData) {
        return new Contact(
            FirstName = contactData.firstName,
            LastName = contactData.lastName,
            AccountId = accountId,
            Phone = contactData.phone,
            Email = contactData.email,
            MailingStreet = addressData.street,
            MailingCity = addressData.city,
            MailingState = addressData.state,
            MailingPostalCode = addressData.postalCode,
            MailingCountry = addressData.country
        );
    }

    public static Opportunity createOpportunityInstance(Id accountId, String accountName, Id contactId) {
        return new Opportunity(
            Name = accountName + '-' + Datetime.now(),
            CloseDate = Date.today().addDays(7),
            StageName = 'Prospecting',
            AccountId = accountId,
            ContactId = contactId,
            Type = 'New Customer'
        );
    }

    public static OpportunityLineItem createOpportunityLineItemInstance(Id opportunityId, PricebookEntry pbe, RestResourceDataModels.SiteProductData product) {
        return new OpportunityLineItem(
            OpportunityId = opportunityId,
            PricebookEntryId = pbe.Id,
            Quantity = product.quantity,
            UnitPrice = pbe.UnitPrice
        );
    }

}