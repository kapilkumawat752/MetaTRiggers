public with sharing class ContactSelector {
    public static List<Contact> getRelatedContacts(Set<Id> accountIds) {
        List<Contact> contacts = new List<Contact>([SELECT AccountId, HomePhone FROM Contact WHERE AccountId IN: accountIds]);
        return contacts;
    }

    public static List<Contact> getContactsToUpdate(Set<Id> accountIds) {
        List<Contact> contacts = new List<Contact>([SELECT AccountId, MailingCity,
                                                                MailingCountry, MailingPostalCode,
                                                                MailingState, MailingStreet
                                                                FROM Contact WHERE AccountId IN: accountIds]);
        return contacts;
    }

}