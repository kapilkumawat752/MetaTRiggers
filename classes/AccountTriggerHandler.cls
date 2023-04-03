public with sharing class AccountTriggerHandler { 
    public static void beforeInsert(List<Account> newList) {
        changeRatingOnAccountCreation(newList); 
        copyAddressOfBillingToShipping(newList);
    }
    
    public static void afterInsert(List<Account> newList) { //NOPMD
        insertContactOnNewAccount(newList);
        insertNewOpportunityForActiveAccount(newList);
        insertNewOpportunity(newList);
        assignTOStandardUserProfiles(newList);
    }
    
    public static void beforeUpdate(List<Account> newList, Map<Id,Account> oldMap) {   //NOPMD
        copyAddressOfBillingToShipping(newList);
        updateDescriptionOfAccount(newList, oldMap);
        changeRatingOnAccountCreation(newList);
        restrictEditAccountBefore7Days(newList);
    }
    
    public static void afterUpdate(List<Account> newList, Map<Id, Account> oldMap) {    //NOPMD
       updatePhoneOnRelatedContactsOfAccount(newList, oldMap);
       updatePhoneOnRelatedContactsOfAccountWithMap(newList, oldMap);
       updateAccountBillingToContactMailingAddressWithMap(newList, oldMap);
       updateAccountBillingToContactMailingAddressWithSOQL(newList, oldMap);
       closeOpportunityForDeactivatedAccount(newList, oldmap);
       updateAccountRevenueRelatedToOpportunity(newList, oldMap);
       //updateOwnerOfContactRelatedToAccounts(newList);  ----  lookup relationship already exist.
    }
    
    public static void beforeDelete(List<Account> oldList) {    //NOPMD
        restrictActiveAccountDeletion(oldList);
        authoriseAccountDeletionOnlyToAdmin(oldList);
        preventAccountDeletionWithRelatedOpportunity(oldList);
        preventAccountDeletionWithRelatedCases(oldList);
    }
    
    public static void afterDelete(List<Account> oldList) {     //NOPMD
        
    } 

    private static void changeRatingOnAccountCreation(List<Account> accounts) {
        for(Account account: accounts) {          
            if(account.Industry != NULL && account.Industry == 'Media') {               
            account.Rating = 'Hot';
            }
        }
    }

    private static void copyAddressOfBillingToShipping(List<Account> accounts) {        //NOPMD
        for(Account account: accounts) {
            if(account.CopyBillingToShipping__c) {  //NOPMD  --  custom field not found error
                if(account.BillingCity != NULL) account.ShippingCity = account.BillingCity;
                if(account.BillingCountry != NULL) account.ShippingCountry = account.BillingCountry;
                if(account.BillingPostalCode != NULL) account.ShippingPostalCode = account.BillingPostalCode;
                if(account.BillingState != NULL) account.ShippingState = account.BillingState;
                if(account.BillingStreet != NULL) account.ShippingStreet = account.BillingStreet;
            } 
        }
    }

    private static void insertContactOnNewAccount(List<Account> accounts) {
        if(!accounts.isEmpty()) {
            List<Contact> contacts = AccountService.contactsToInsert(accounts);
            if(!contacts.isEmpty()) {
                insert contacts;    //NOPMD  -- Validate CRUD permission before SOQL/DML operation
            }
        }
    }

    private static void insertNewOpportunityForActiveAccount(List<Account> accounts) {
        if(!accounts.isEmpty()) {
            List<Opportunity> opportunitiesToUpdate = AccountService.insertOpportunityForAccount(accounts);
            if(!opportunitiesToUpdate.isEmpty()) {
                insert opportunitiesToUpdate;        //NOPMD  --  Validate CRUD permission before SOQL/DML operation
            }
        }
    }

    private static void insertNewOpportunity(List<Account> accounts) {
        if(!accounts.isEmpty()) {
            List<Opportunity> opportunitiesToUpdate = AccountService.insertOpportunityForAccount(accounts);
            if(!opportunitiesToUpdate.isEmpty()) {
                insert opportunitiesToUpdate;        //NOPMD  --  Validate CRUD permission before SOQL/DML operation
            }
        }
    }

    private static void updateDescriptionOfAccount(List<Account> accounts, Map<Id, Account> oldMap) {       //Scenario:2 Method
            for(Account account: accounts) {
                if (oldMap.containsKey(account.Id) && account.Phone != oldMap.get(account.Id).Phone) {
                    account.Description = 'Phone is updated! Old Value: '+account.phone+' New Value: '+oldMap.get(account.Id).Phone;
                }
            }
    }
    
     // Scenario:4
    private static void updatePhoneOnRelatedContactsOfAccount(List<Account> accounts, Map<Id, Account> accountMap) {
        List<Contact> contacts = AccountService.updateRelatedPhoneOfContactOfAccount(accounts, accountMap);
        if(!contacts.isEmpty())
            update contacts;
    }

    // Scenario:3
    private static void updatePhoneOnRelatedContactsOfAccountWithMap(List<Account> accounts, Map<Id, Account> accountMap) {
        Map<Id, String> accountPhoneMap = new MAp<Id, String>();
        for(Account account: accounts) {
            if(account.Phone != NULL && accountMap.get(account.Id).Phone != account.Phone) {
                accountPhoneMap.put(account.Id, account.Phone);
            }
        }
        if(!accountPhoneMap.isEmpty()) {
            List<Contact> contacts = AccountService.updateRelatedContact(accountPhoneMap);
            update contacts;
        }      
    }

    //Scenario: 5 handler class
    private static void updateAccountBillingToContactMailingAddressWithMap(List<Account> accounts, Map<Id, Account> accountMap) {
        Map<Id,Account> relatedAccountIds = new Map<Id, Account>();
        for(Account account: accounts) {
            if(accountMap.get(account.Id).BillingCity != account.BillingCity
                || accountMap.get(account.Id).BillingCountry != account.BillingCountry 
                || accountMap.get(account.Id).BillingPostalCode != account.BillingPostalCode 
                || accountMap.get(account.Id).BillingState != account.BillingState 
                || accountMap.get(account.Id).BillingStreet != account.BillingStreet) {
                relatedAccountIds.put(account.Id, account);
            }
        }

        if(!relatedAccountIds.isEmpty()) {
            List<Contact> updateContacts = AccountService.updateMailingAddressOfContactOfRelatedAccount(relatedAccountIds);
            update updateContacts;
        }      
    }

    //Scenario: 6 Handler Class---
    private static void updateAccountBillingToContactMailingAddressWithSOQL(List<Account> accounts, Map<Id, Account> accountMap) {
        List<Contact> contacts = AccountService.updateBillingToMailingAddress(accounts, accountMap);
        if(!contacts.isEmpty())
            update contacts;
    }

    //Scenario: 8 --- When Account Active to deactive
    private static void closeOpportunityForDeactivatedAccount(List<Account> accounts, Map<Id,Account> oldmap) {
        Set<Id> accountIds = new Set<Id>();
        for(Account account: accounts) {
            if(account.Active__c == 'No' && oldmap.get(account.Id).Active__c == 'Yes') {                //NOPMD
                accountIds.add(account.Id);
            }
        }
        List<Opportunity> opportunities = AccountService.opportunitiesToClose(accountIds);
        if(!opportunities.isEmpty())
            Update opportunities;                       //NOPMD
    }

    //Scenario: 9 --- prevent from deleting Active Account
    private static void restrictActiveAccountDeletion (List<Account> accounts) {
        for(Account account: accounts) {
            if(account.Active__c == 'Yes') {
                account.addError('Can not delete active account');
            }
        }
    }

    //Scenario:10  --- prevent record from editing created within 7 days
    private static void restrictEditAccountBefore7Days(List<Account> recentaccounts) {
        for(Account account: recentaccounts) {
            if(System.today() <= (account.CreatedDate).addDays(7)) {
                account.addError('Can not Edit New Account till 7 days from Created Date!!!');
            }
        }
    }

    //Scenario: 13   ---- Give access of deleting account to only System Admin
    private static void authoriseAccountDeletionOnlyToAdmin(List<Account> oldaccounts) {
        for(Account account: oldaccounts) {
            String userProfileName = [SELECT Name FROM profile WHERE Id =: UserInfo.getProfileId()].Name;
            if(userProfileName != 'System Administrator') {
                account.addError('You Do not have access to delete this account \nPlease Contact System Administrator!!!');
            }
        }
    }

    //Scenario:15   --- Prevent Account Deletion with related Opportunity.
    private static void preventAccountDeletionWithRelatedOpportunity(List<Account> accounts) {
        for(Account account: accounts) {
            if([SELECT Id FROM Opportunity WHERE AccountId = :account.Id] != NULL) {
                account.addError('Can not Delete Account with related Opportunity!');
            }
        }
    }

    //Scenario:16   --- Prevent Account Deletion with related Cases.
    private static void preventAccountDeletionWithRelatedCases(List<Account> accounts) {
        for(Account account: accounts) {
            if([SELECT Id FROM Case WHERE AccountId = :account.Id] != NULL) {
                account.addError('Can not Delete Account with related Opportunity!');
            }
        }
    }
    
    //Scenario: 23  ---
    private static void updateAccountRevenueRelatedToOpportunity(List<Account> accounts, Map<Id,Account> accountMap) { //Q23
        List<Opportunity> opportunities = [SELECT Id, StageName, Annual_Revenue__c, Account.AnnualRevenue, AccountId, Account.Active__c FROM Opportunity WHERE AccountId IN: accountMap.keySet()];
        
        for (Opportunity opportunity : opportunities) {
            if (opportunity.Account.Active__c != accountMap.get(opportunity.AccountId).Active__c 
                && opportunity.Account.Active__c == 'no' 
                && accountMap.get(opportunity.AccountId).Active__c == 'yes' 
                && opportunity.StageName != 'Closed Won') {
                opportunity.StageName = 'Close Lost';
            }
            if (opportunity.Account.AnnualRevenue != NULL && opportunity.Account.AnnualRevenue !=  accountMap.get(opportunity.AccountId).AnnualRevenue) {
                opportunity.Annual_Revenue__c = opportunity.Account.AnnualRevenue;
            }
        }
        
        update opportunities;
    }

    //Scenario: 27 & 28 ----- Check if Error arises due to Lookup RelationShip.
    // private Static void updateOwnerOfContactRelatedToAccounts(List<Account> accounts) {
    //     List<Contact> accountIds = [SELECT AccountId, OwnerId, Account.OwnerId, FROM Contact WHERE AccountId IN : accounts];
    //     List<Contact> contacts = new List<Contact>();
    //     for(Contact contact: accountIds) {
    //         if(contact.Account.OwnerId != contact.OwnerId) {
    //             contact.OwnerId = contact.Account.OwnerId;
    //             contacts.add(contact);
    //         }
    //         update contacts;
    //     }
    // }

    //Scenario:31 -----  Set standard User OWD access level
    public static void assignTOStandardUserProfiles(List<Account> accounts) { //Q31
        List<AccountShare> accountShares = new List<AccountShare>();
        List<User> standardUsers = [SELECT Id FROM User WHERE Profile.Name = 'Standard User'];
        
        for (Account account : accounts) {
            for (User user : standardUsers) {
                AccountShare accountShare = new AccountShare();
                accountShare.AccountId = account.Id;
                accountShare.UserOrGroupId = user.Id;
                accountShare.AccountAccessLevel = 'Read';
                accountShare.RowCause = Schema.AccountShare.RowCause.Manual;
                accountShares.add(accountShare);
            }
        }
        
        insert accountShares;
    }

}