public with sharing class AccountService {

    public static List<Contact> contactsToInsert(List<Account> accounts) {
        List<Contact> contacts = new List<Contact>();
            for(Account account: accounts) {
                if(account.Contact__c == true) {
                    Contact contact = new Contact();
                    contact.AccountId = account.Id;
                    contact.LastName = account.Name;
                    contact.Phone = account.Phone;
                    contacts.add(contact);
                }
            }
        return !contacts.isEmpty() ? contacts : NULL;
    }

    public static List<Opportunity> insertOpportunityForAccount(List<Account> accounts) {
        List<Opportunity> opportunities = new List<Opportunity>();
            for(Account account: accounts) {
                if(account.Opportunity__c == true && account.Active__c == 'Yes') {      //NOPMD Custom Field not available Error
                    if(account.Id != NULL) {
                        Opportunity opportunity = new Opportunity();
                        opportunity.AccountId = account.Id;
                        opportunity.Name = account.Name;
                        opportunity.CloseDate = System.today();
                        opportunity.StageName = 'Qualification';       
                        opportunities.add(opportunity);
                    }
                }
            }
        return opportunities;
    }

    public static List<Opportunity> createOpportunityForAccount(List<Account> accounts) {
        List<Opportunity> opportunities = new List<Opportunity>();
            for(Account account: accounts) {
                if(account.Id != NULL) {
                    Opportunity opportunity = new Opportunity();
                    opportunity.AccountId = account.Id;
                    opportunity.Name = account.Name;
                    opportunity.CloseDate = System.today();
                    opportunity.StageName = 'Qualification';       //NOPMD Custom Field not available Error
                    opportunities.add(opportunity);
                }
            }
        return opportunities;
    }

    public static List<Contact> updateRelatedPhoneOfContactOfAccount(List<Account> accounts, Map<Id, Account> accountMap) {     //Scenario 4 - service method
    List<Contact> contacts = new List<Contact>(); 
        for(Account account: accounts) {
            List<Contact> relatedContact = new List<Contact>([SELECT Id, HomePhone FROM Contact WHERE AccountId = :account.Id]);
                for(Contact contact: relatedContact) {
                    if(accountMap.containsKey(account.Id) && account.Phone != contact.HomePhone) {
                        contact.HomePhone = account.Phone;
                        contacts.add(contact);
                }
            }
        }
        return contacts;
    }
    
    public static List<Contact> updateRelatedContact(Map<Id, String> accountMap) {      //Scenario:3 Method
        List<Contact> contacts = ContactSelector.getRelatedContacts(accountMap.keySet());
        if(!contacts.isEmpty()) {
            for(Contact contact: contacts) {
                contact.HomePhone = accountMap.get(contact.AccountId);
            }
        }
        return contacts;
    }

    public static List<Contact> updateMailingAddressOfContactOfRelatedAccount(Map<Id,Account> accountMap) {     //Scenario:5 Method
        List<Contact> contacts = ContactSelector.getContactsToUpdate(accountMap.keySet());
            for(Contact contact: contacts) {
                contact.MailingCity = accountMap.get(contact.AccountId).BillingCity;
                contact.MailingCountry = accountMap.get(contact.AccountId).BillingCountry;
                contact.MailingPostalCode = accountMap.get(contact.AccountId).BillingPostalCode;
                contact.MailingState = accountMap.get(contact.AccountId).BillingState;
                contact.MailingStreet = accountMap.get(contact.AccountId).BillingStreet;
            }
        return contacts;
    }

    public static List<Contact> updateBillingToMailingAddress(List<Account> accounts, Map<Id, Account> accountMap) {     //Scenario 6 - service method
        List<Contact> relatedContacts = new List<Contact>(); 
        for(Account account: accounts) {
            List<Contact> contacts = new List<Contact>([SELECT AccountId, MailingCity,
                                                                    MailingCountry, MailingPostalCode,
                                                                    MailingState, MailingStreet
                                                                    FROM Contact WHERE AccountId IN: accountMap.keySet()]);
            if(accountMap.containsKey(account.Id)) {
                for(Contact contact: contacts) {
                    contact.MailingCity = accountMap.get(contact.AccountId).BillingCity;
                    contact.MailingCountry = accountMap.get(contact.AccountId).BillingCountry;
                    contact.MailingPostalCode = accountMap.get(contact.AccountId).BillingPostalCode;
                    contact.MailingState = accountMap.get(contact.AccountId).BillingState;
                    contact.MailingStreet = accountMap.get(contact.AccountId).BillingStreet;
                    relatedContacts.add(contact);
                }
            }
        }
        return relatedContacts;
    }

    //Senario: 8 Method
    public static List<Opportunity> opportunitiesToClose(Set<Id> accountIds) {
        List<Opportunity> opportunities = [SELECT Id, AccountId, StageName FROM Opportunity WHERE AccountId IN: accountIds];
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        for(Opportunity opportunity: opportunities) {
            if(opportunity.StageName != 'Closed Won' && opportunity.StageName != 'Closed Lost') {
                opportunity.StageName = 'Closed Lost';
                opportunitiesToUpdate.add(opportunity);
            }
        }
        return opportunitiesToUpdate;
    }
}