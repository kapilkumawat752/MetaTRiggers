trigger CaseTrigger on Case (before insert, before update, before delete, after insert, after update, after delete) {   //NOPMD  --  Unused parameter errror

    switch on Trigger.operationType {
        
        when BEFORE_INSERT {
           
        }
        
        when AFTER_INSERT {
            CaseTriggerHandler.afterInsert(Trigger.New);
        }
        
        when BEFORE_UPDATE {
            
        }
        
        when AFTER_UPDATE {
            CaseTriggerHandler.afterUpdate(Trigger.New);
        }
        
        when BEFORE_DELETE {
           
        }
        
        when AFTER_DELETE {
               
        }
        
    }
 
}