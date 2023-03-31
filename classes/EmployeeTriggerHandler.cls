public with sharing class EmployeeTriggerHandler {
    public static void beforeInsert(List<Employee__c> newList) {   //NOPMD -- Blank method Error
        
    }
     
    public static void afterInsert(List<Employee__c> newList) { 
        updatePresentEmployeeCount(newList);
    }
     
    public static void beforeUpdate(List<Employee__c> newList, Map<Id, Employee__c> oldMap) {   //NOPMD -- Blank method Error
         
    }
     
    public static void afterUpdate(List<Employee__c> newList) {    //NOPMD -- Blank method Error
        
    }
     
    public static void beforeDelete(List<Employee__c> oldList) {    //NOPMD -- Blank method Error
         
    }
     
    public static void afterDelete(List<Employee__c> oldList, List<Employee__c> newList) {     //NOPMD -- Blank method Error
        updatedeletedEmployeeCountOnAccount(oldList);
        updatePresentEmployeeCount(newList);
    }

    public static void afterUndelete(List<Employee__c> oldList) {
        restoreDeletedEmployee(oldList);
        updatePresentEmployeeCount(oldList);
    }

    //Scenario: 17  ---- 
    private static void updatedeletedEmployeeCountOnAccount(List<Employee__c> employees) {
        Set<Id> accountIds = new Set<Id>();
        for(Employee__c employee: employees) {
            accountIds.add(employee.Id);
        }
        List<Account> accounts = [SELECT Id, Employee_Left_Count__c, (SELECT Id, Account__c FROM Employees__r ) FROM Account WHERE Id = :accountIds];           //NOPMD
        for(Account account: accounts) {
            account.Employee_Left_Count__c = account.Employees__r.size();
        }
        update accounts;
    }

    //Scenario: 18 & 19  -----
    private static void restoreDeletedEmployee(List<Employee__c> deletedEmployees) {
        Undelete deletedEmployees;
        EmployeeTriggerHandler.updatedeletedEmployeeCountOnAccount(deletedEmployees);
        for(Employee__c employee: deletedEmployees) {
            employee.Active__c = true;
        }
        Update deletedEmployees;
    }

    //Scenario: 20   ----   Current Employee Count
    private static void updatePresentEmployeeCount(List<Employee__c> employees) {
        Set<Id> accountIds = new Set<Id>();
        for (Employee__c emp : employees) {     // trigger.new for insert and undelete
            accountIds.add(emp.Account__c);     //trigger.old for delete operation.
        }
        List<Account> accountsToUpdate = new List<Account>();
        for (Id accId : accountIds) {
            Account account = [SELECT Id, Present_Employee_Count__c, (SELECT Id FROM Employees__r WHERE Active__c = true) 
                                        FROM Account WHERE Id = :accId];
            account.Present_Employee_Count__c = account.Employees__r.size();
            accountsToUpdate.add(account);
        }
        Update accountsToUpdate;
    }

}