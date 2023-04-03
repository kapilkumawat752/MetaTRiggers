trigger UserTrigger on User (before insert, before update, before delete, after insert, after update, after delete) {  //NOPMD  --  Unused parameter error.
	
    switch on Trigger.operationType {
        
        when BEFORE_INSERT {
        	
        }
        
        when AFTER_INSERT {
            UserTriggerHAndler.afterInsert(Trigger.new);
        }
        
        when BEFORE_UPDATE {
            
        }
        
        when AFTER_UPDATE {
           UserTriggerHAndler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
        
        when BEFORE_DELETE {
           
        }
        
        when AFTER_DELETE {
            
        }
        
    }

}