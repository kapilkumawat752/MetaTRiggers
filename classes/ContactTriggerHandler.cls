public with sharing class ContactTriggerHandler {

    public static void beforeInsert(List<Contact> newList) {   //NOPMD -- Blank method Error
        restrictNewContactWithSameEmail(newList);
    }
     
    public static void afterInsert(List<Contact> newList) { 
        sendEmailOnContactCreate(newList);
    }
     
    public static void beforeUpdate(List<Contact> newList, Map<Id, Contact> oldMap) {   //NOPMD -- Blank method Error
         
    }
     
    public static void afterUpdate(List<Contact> newList) {    //NOPMD -- Blank method Error
        
    }
     
    public static void beforeDelete(List<Contact> oldList) {    //NOPMD -- Blank method Error
         
    }
     
    public static void afterDelete(List<Contact> oldList) {     //NOPMD -- Blank method Error
         
    }

    //Scenario:21  ---
    private static void sendEmailOnContactCreate(List<Contact> newContacts) {
        EmailTemplate emailId = [SELECT Id, DeveloperName,Name FROM EmailTemplate WHERE Name = 'New Contact Greeting'];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (Contact con : newContacts) {
            if (con.Email != null && con.Email != '') {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new List<String>{ con.Email });
                email.setTemplateId(emailId.Id);
                email.setTargetObjectId(con.Id);
                emails.add(email);
            }
        }
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }

    //Scenario:30 --- Error for Duplicate new Contact having same Email.
    private static void restrictNewContactWithSameEmail(List<Contact> newContacts) { //Q30
        Set<String> contactEmails = new Set<String>();
        List<Contact> contacts = [SELECT Id, Email FROM Contact];
        for (Contact contact : contacts) {
            if (contact.Email != NULL) {
                contactEmails.add(contact.Email);
            }
        }
        for (Contact contact : contacts) {
            if (contactEmails.contains(contact.Email)) {
                contact.addError('This email is exist in another contact you can not create contact with this email');
            }
        }
    }
}