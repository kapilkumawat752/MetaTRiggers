public with sharing class UserTriggerHAndler {

    public static void beforeInsert(List<User> newList) {   //NOPMD -- Blank method Error
        
    }
     
    public static void afterInsert(List<User> newList) { 
        assignSystemAdminToPublicAdminGroup(newList);
    }
     
    public static void beforeUpdate(List<User> newList, Map<Id, User> oldMap) {   //NOPMD -- Blank method Error
         
    }
     
    public static void afterUpdate(List<User> newList, Map<Id, User> oldmap) {    //NOPMD -- Blank method Error
        updateAssignSystemAdminToPublicAdminGroup(newList, oldmap);
    }
     
    public static void beforeDelete(List<User> oldList) {    //NOPMD -- Blank method Error
         
    }
    
    //Scenario: 29  -----  insert System Administrator to Admin Public Group
    private static void assignSystemAdminToPublicAdminGroup(List<User> users) {
        Id IdOfGroup = [SELECT Id FROM Group WHERE Name ='Admins' LIMIT 1].Id;
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        List<GroupMember> groupMembers = new List<GroupMember>();

        for (User user : users) {
            if (user.ProfileId == adminProfileId && user.IsActive == true) {
                groupMembers.add(new GroupMember(GroupId = IdOfGroup, UserOrGroupId = user.Id));
            }
        }
        if (!groupMembers.isEmpty()) {
            insert groupMembers;
        }
    }

    private static void updateAssignSystemAdminToPublicAdminGroup(List<User> users, Map<Id, User> userMap) {
        Id IdOfGroup = [SELECT Id FROM Group WHERE Name ='Admins' LIMIT 1].Id;
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        List<GroupMember> groupMembers = new List<GroupMember>();

        for (User user : users) {
            if ((user.ProfileId != userMap.get(user.Id).ProfileId 
                 || user.IsActive != userMap.get(user.Id).IsActive) 
                 && user.ProfileId == adminProfileId 
                 && user.IsActive == true) {
                groupMembers.add(new GroupMember(GroupId = IdOfGroup, UserOrGroupId = user.Id));
            }
        }
        if (!groupMembers.isEmpty()) {
            insert groupMembers;
        }
    }

}