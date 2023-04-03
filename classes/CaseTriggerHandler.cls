public with sharing class CaseTriggerHandler {  //NOPMD
    public static void beforeInsert(List<Case> newList) {   //NOPMD -- Blank method Error
        
    }
     
    public static void afterInsert(List<Case> newList) { 
        insertCaseNumberOnAccount(newList);
        insertTotalCaseTypesOnAccount(newList);
    }
     
    public static void beforeUpdate(List<Case> newList, Map<Id, Case> oldMap) {   //NOPMD -- Blank method Error
         
    }
     
    public static void afterUpdate(List<Case> newList) {    //NOPMD -- Blank method Error
        insertCaseNumberOnAccount(newList);
    }
     
    public static void beforeDelete(List<Case> oldList) {    //NOPMD -- Blank method Error
         
    }
     
    public static void afterDelete(List<Case> oldList) {     //NOPMD -- Blank method Error
         
    }

    private static void insertCaseNumberOnAccount(List<Case> cases) {
        if(!cases.isEmpty()){
            List <Account> accountsToUpdate = CaseService.updateCaseNumberOnAccount(cases);
            if(!accountsToUpdate.isEmpty()) {
                UPDATE accountsToUpdate;        //NOPMD -- Validate CRUD permission before SOQL/DML operation
            }
        }
    }
    
    //Scenario:22 --- 
    private static void insertTotalCaseTypesOnAccount(List<Case> newCases) {
        RecordType partnerRecordId = [Select ID,Name from RecordType where Name = 'Partner Case'];
        RecordType customerRecordId = [Select ID,Name from RecordType where Name = 'Customer Case'];
        Map<Id, Account> accountMap = new Map<Id, Account>();
        Set<Id> partnerAccountIds = new Set<Id>();
        Set<Id> customerAccountIds = new Set<Id>();
        for (Case c : newCases) {
            if (partnerRecordId.Id == c.RecordTypeId) {
                partnerAccountIds.add(c.AccountId);
            } else if (customerRecordId.Id == c.RecordTypeId) {
                customerAccountIds.add(c.AccountId);
            }
        }
        List<Account> partnerAccountsToUpdate = [SELECT Id, Total_Partner_Cases__c FROM Account WHERE Id IN :partnerAccountIds];
        for (Account account : partnerAccountsToUpdate) {
            if(account.Total_Partner_Cases__c == null) {
                account.Total_Partner_Cases__c = 1;
            }
            else {
                account.Total_Partner_Cases__c = account.Total_Partner_Cases__c + 1;
            }
            accountMap.put(account.Id, account);
        }
        List<Account> customerAccountsToUpdate = [SELECT Id, Total_Customer_Cases__c FROM Account WHERE Id IN :customerAccountIds];
        for (Account account : customerAccountsToUpdate) {
            if(account.Total_Customer_Cases__c == null) {
                account.Total_Customer_Cases__c = 1;
            }
            else {
                account.Total_Customer_Cases__c = account.Total_Customer_Cases__c + 1;
            }
            accountMap.put(account.Id, account);
        }
        update accountMap.values();
    } 
    
}