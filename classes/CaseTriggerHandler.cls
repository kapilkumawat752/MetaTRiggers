public with sharing class CaseTriggerHandler {  //NOPMD
    public static void beforeInsert(List<Case> newList) {   //NOPMD -- Blank method Error
        
    }
     
    public static void afterInsert(List<Case> newList) { 
        insertCaseNumberOnAccount(newList);
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

}