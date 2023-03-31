trigger OpportunityTrigger on Opportunity (before insert, before update, before delete, after insert, after update, after delete) {  //NOPMD  --  Unused parameter error.
	
    switch on Trigger.operationType {
        
        when BEFORE_INSERT {
        	OpportunityTriggerHandler.beforeInsert(Trigger.new);
        }
        
        when AFTER_INSERT {
            OpportunityTriggerHandler.afterInsert(Trigger.new);
        }
        
        when BEFORE_UPDATE {
            OpportunityTriggerHandler.beforeUpdate(Trigger.new);
        }
        
        when AFTER_UPDATE {
           OpportunityTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
        
        when BEFORE_DELETE {
           OpportunityTriggerHandler.beforeDelete(Trigger.old);
        }
        
        when AFTER_DELETE {
               
        }
        
    }
 
}