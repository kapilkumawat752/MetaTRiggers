public with sharing class PositionTriggerHandler {
    public static void beforeInsert(List<Position__c> newList) {   //NOPMD
        insertMinMaxDateFields(newList);
    }
     
    public static void afterInsert(List<Position__c> newList) { //NOPMD
         
    }
     
    public static void beforeUpdate(List<Position__c> newList, Map<Id, Position__c> oldMap) {   //NOPMD
         
    }
     
    public static void afterUpdate(List<Position__c> newList, Map<Id, Position__c> oldMap) {    //NOPMD
        
    }
     
    public static void beforeDelete(List<Position__c> oldList) {    //NOPMD
         
    }
     
    public static void afterDelete(List<Position__c> oldList) {     //NOPMD
         
    } 
    private static void insertMinMaxDateFields(List<Position__c> positions) {
        for(Position__c position: positions) {          
            if(position.Open_Date__c == NULL) {               
                position.Open_Date__c = System.today();
            }
            if(position.Min_Pay__c == NULL) {
                position.Min_Pay__c = 10000;
            }
            if(position.Max_Pay__c == NULL) {
                position.Max_Pay__c = 15000;
            }
        }
    }
}