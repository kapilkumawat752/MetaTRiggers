trigger EmployeeTrigger on Employee__c (before insert, before update, before delete, after insert, after update, after delete) {   //NOPMD  --  Unused parameter errror

    switch on Trigger.operationType {
        
        when BEFORE_INSERT {
           
        }
        
        when AFTER_INSERT {
            
        }
        
        when BEFORE_UPDATE {
            
        }
        
        when AFTER_UPDATE {
            
        }
        
        when BEFORE_DELETE {
           
        }
        
        when AFTER_DELETE {
            EmployeeTriggerHandler.afterInsert(Trigger.old);
        }

        when AFTER_UNDELETE {
            EmployeeTriggerHandler.afterUndelete(Trigger.old);
        }
        
    }

}