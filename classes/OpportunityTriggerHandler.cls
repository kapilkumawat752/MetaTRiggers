public with sharing class OpportunityTriggerHandler {
    public static void beforeInsert(List<Opportunity> newList) {
        changeOpportunityByAmount(newList);
        updateOpportunityStage(newList);
        updateRelatedAccountsToOpportunity(newList);
    }
    
    public static void afterInsert(List<Opportunity> newList) { //NOPMD
        updateOpportunityAmount(newList);
        
    }
    
    public static void beforeUpdate(List<Opportunity> newList) {   //NOPMD
        updateOpportunityStage(newList);
        preventOpportunityUpdateWithoutClosedLostReason(newList);
    }
    
    public static void afterUpdate(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {    //NOPMD
       updateCurrentUserNameToTaskForNewOpportunity(newList, oldMap);
       updateRelatedAccountsToOpportunity(newList, oldMap);
       updateOpportunityStage(newList, oldmap);
    }
    
    public static void beforeDelete(List<Opportunity> oldList) {    //NOPMD
        authoriseClosedOpportunityDeletionOnlyToAdmin(oldList);
    }
    
    public static void afterDelete(List<Opportunity> oldList) {     //NOPMD
        updateRelatedAccountsToOpportunity(oldList);
    } 

    private static void changeOpportunityByAmount(List<Opportunity> opportunities) {
        for(Opportunity opp: opportunities) {
            if(opp.Amount != NULL && opp.Amount > 100000) {
                opp.Description = 'Hot Opportunity';
            }
        }
    }

    private static void updateOpportunityAmount(List<Opportunity> opportunities) {
        if(!opportunities.isEmpty()) {
            List<Account> accountsToUpdate = OpportunityService.updateOpportunityAmountOnAccount(opportunities);
            if(!accountsToUpdate.isEmpty()) {
                UPDATE accountsToUpdate;        //NOPMD  --  Validate CRUD permission before SOQL/DML operation
            }
        }
    }

    // Scenario: 2
    private static void updateOpportunityStage(List<Opportunity> opportunities) {
        for(Opportunity opportunity: opportunities) {
            if(opportunity.StageName == 'Closed Won')
                opportunity.Description = 'Opportunity is Closed Won!';
            if(opportunity.StageName == 'Closed Lost')
                opportunity.Description = 'Opportunity is Closed Lost!';
            else
                opportunity.Description = 'Opportunity is Open!';
        }
    }

    //Scenario: 7  --- opportunity task
    private static void updateCurrentUserNameToTaskForNewOpportunity(List<Opportunity> opportunities, Map<Id,Opportunity> oldMap) {
        List<Task> createTasks = new List<Task>();
        for(Opportunity opportunity: opportunities) {
            if(opportunity.StageName != oldMap.get(opportunity.Id).StageName && oldMap.containsKey(opportunity.Id)) {
                Task newTask = new Task(WhatId = opportunity.Id, OwnerId = UserInfo.getUserId());
                    newTask.Subject = opportunity.StageName;
                    newTask.Status = 'In Progress';
                    createTasks.add(newTask);
            }
        }
        Insert createTasks;
    }

    //Scenario: 12   --- Prevent from update without Closed Lost Reason.
    private static void preventOpportunityUpdateWithoutClosedLostReason(List<Opportunity> opportunities) {
        for(Opportunity opportunity: opportunities) {
            if(opportunity.StageName == 'Closed Lost' && opportunity.Closed_Lost_Reason__c != NULL) {
                opportunity.addError('Please specify Reason for Lost Opportunity!');
            }
        }
    }

    //Scenario: 14   ---- Give access of deleting opportunity to only System Admin
    private static void authoriseClosedOpportunityDeletionOnlyToAdmin(List<Opportunity> opportunities) {
        for(Opportunity opportunity: opportunities) {
            String userProfileName = [SELECT Name FROM profile WHERE Id =: UserInfo.getProfileId()].Name;
            if(opportunity.StageName == 'Closed Lost' || opportunity.StageName == 'Closed Won') {
                if(userProfileName != 'System Administrator') {
                    opportunity.addError('You Do not have access to delete this Opportunity \nPlease Contact System Administrator!!!');
                }
            }
        }
    }

    //Scenario: 23 ---- part 2 (part 1 in AccountTriggerHAndler class)
    private static void updateRelatedAccountsToOpportunity(List<Opportunity> opportunities) { //Q23
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opportunity : opportunities) {
            accountIds.add(opportunity.AccountId);
        }
        List<Account> accounts = UpdateOpportunityRelatedAccounts(accountIds);
        if (!accounts.isEmpty()) {
            update accounts;
        }
    }

    //Scenario: 23 ---- part 2 (part 1 in AccountTriggerHAndler class)
    private static void updateRelatedAccountsToOpportunity(List<Opportunity> opportunities, Map<Id, Opportunity> opportunityMap) {
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opportunity : opportunities) {
            if (opportunity.Amount != opportunityMap.get(opportunity.Id).Amount) {
                accountIds.add(opportunity.AccountId);
            }
        }
        List<Account> accounts = UpdateOpportunityRelatedAccounts(accountIds);
        if (!accounts.isEmpty()) {
            update accounts;
        }
    }

    //Scenario: 23 ---- part 2 (part 1 in AccountTriggerHAndler class)
    public static List<Account> updateOpportunityRelatedAccounts(Set<Id> AccountIds) {
        List<Account> accounts = new List<Account>();
        AggregateResult[] groupedResults = [SELECT AccountId, Sum(Amount)annulRevenue FROM Opportunity  WHERE AccountId IN: AccountIds GROUP BY AccountId];

        for (AggregateResult variable : groupedResults) {
            String accountId = String.valueOf(variable.get('AccountId'));
            Integer annualRevenue = Integer.valueOf(variable.get('annulRevenue'));
            accounts.add(new Account(Id = accountId, AnnualRevenue = annualRevenue));
        }

        return accounts;
    }

    // Scenario: 26 --- (Similar to Scenario:2)
    private static void updateOpportunityStage(List<Opportunity> opportunities, Map<Id,Opportunity> oldmap) {
        for(Opportunity opportunity: opportunities) {
            if(opportunity.StageName != oldmap.get(opportunity.Id).StageName) {
                if(opportunity.StageName == 'Closed Won')
                    opportunity.Description = 'Opportunity is Closed Won!';
                if(opportunity.StageName == 'Closed Lost')
                    opportunity.Description = 'Opportunity is Closed Lost!';
            }
        }
    }
}