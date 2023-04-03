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
     
    public static void afterDelete(List<Employee__c> oldList) {     //NOPMD -- Blank method Error
        updatedeletedEmployeeCountOnAccount(oldList);
        updatePresentEmployeeCount(oldList);
    }

    public static void afterUndelete(List<Employee__c> newList) {
        restoreDeletedEmployee(newList);
        updatedeletedEmployeeCountOnAccount(newList);
        updatePresentEmployeeCount(newList);
    }

    //Scenario: 17  ---- 
    private static void updatedeletedEmployeeCountOnAccount(List<Employee__c> employees) {
        Set<Id> accountIds = new Set<Id>();
        for (Employee__c employee : employees) {
            accountIds.add(employee.Account__c);
        }
        List<Account> accountsToUpdate = new List<Account>();
        for (AggregateResult resultArray : [SELECT Account__c accId, COUNT(Id) countEmployee FROM Employee__c
                                                WHERE Account__c IN :accountIds GROUP BY Account__c]) {
            accountsToUpdate.add(new Account(Id = (Id)resultArray.get('accId'),
            Employee_Left_Count__c = (Integer)resultArray.get('countEmployee')));
        }
        update accountsToUpdate;
    }
   
   //Scenario: 18  -----
    private static void restoreDeletedEmployee(List<Employee__c> deletedEmployees) {
        Set<String> employeeIds = new Set<String>();
        for (Employee__c employee : deletedEmployees) {
            employeeIds.add(employee.Id);
        }
        List<Employee__c> employeequery = [SELECT Active__c FROM Employee__c WHERE Id IN :employeeIds];
        for(Employee__c employee : employeequery) {
            employee.Active__c	= True;
        }
        update employeequery;
    }

    //Scenario: 18 & 19  -----
    // private static void restoreDeletedEmployee(List<Employee__c> deletedEmployees) {
    //     Undelete deletedEmployees;
    //     EmployeeTriggerHandler.updatedeletedEmployeeCountOnAccount(deletedEmployees);
    //     for(Employee__c employee: deletedEmployees) {
    //         employee.Active__c = true;
    //     }
    //     Update deletedEmployees;
    // }

    //Scenario: 20   ----   Current Employee Count
    private static void updatePresentEmployeeCount(List<Employee__c> employees) {
        Set<Id> accountIds = new Set<Id>();
        List<Account> accountsToUpdate = new List<Account>();
        for (Employee__c employee : employees) {
            accountIds.add(employee.Account__c);
        }
        List<Account> accountList = [SELECT Id,Present_Employee_Count__c, (SELECT Id FROM Employees__r) FROM Account WHERE Id IN : accountIds];
        for(Account account : accountList) {
            Account a = new Account();
            a.Id = account.Id;
            a.Present_Employee_Count__c = account.Employees__r.size();
            accountsToUpdate.add(a);
        }
        update accountsToUpdate;
    }

    //Scenario: 20   ----   Current Employee Count
    // private static void updatePresentEmployeeCount(List<Employee__c> employees) {
    //     Set<Id> accountIds = new Set<Id>();
    //     for (Employee__c emp : employees) {     // trigger.new for insert and undelete
    //         accountIds.add(emp.Account__c);     //trigger.old for delete operation.
    //     }
    //     List<Account> accountsToUpdate = new List<Account>();
    //     for (Id accId : accountIds) {
    //         Account account = [SELECT Id, Present_Employee_Count__c, (SELECT Id FROM Employees__r WHERE Active__c = true) 
    //                                     FROM Account WHERE Id = :accId];
    //         account.Present_Employee_Count__c = account.Employees__r.size();
    //         accountsToUpdate.add(account);
    //     }
    //     Update accountsToUpdate;
    // }

}