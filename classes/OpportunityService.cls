public with sharing class OpportunityService {
    public static List<Account> updateOpportunityAmountOnAccount(List<Opportunity> opportunities) {
        List<Account> accounts = new List<Account>();
        for(Opportunity opportunityAmount: opportunities) {
            if(opportunityAmount.Amount != NULL && opportunityAmount.AccountId != NULL) {
                Account account = new Account();
                account.Id = opportunityAmount.AccountId;
                account.Opportunity_Amount__c = opportunityAmount.Amount;       //NOPMD Custom Field not available Error
                accounts.add(account);
            }
        }
        return accounts;
    }

}