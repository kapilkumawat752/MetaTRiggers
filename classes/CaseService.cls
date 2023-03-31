public with sharing class CaseService {
    public static List<Account> updateCaseNumberOnAccount(List<Case> cases) {
        List<Account> accountsToUpdate = new List<Account>();
        for(Case newCase: cases) {
            if(newCase.AccountId != NULL) {
                Account account = new Account(Id = newCase.AccountId, Latest_Case_Number__c = newCase.CaseNumber);      //NOPMD Custom field not fetching in VS Code.          
                accountsToUpdate.add(account);
            }
        }
        return  accountsToUpdate;
    }
}