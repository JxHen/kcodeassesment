public with sharing class ContactSearchController {
  public ContactSearchController() {}

  @AuraEnabled(cacheable=true)
  public static List<Contact> getContacts(String searchName, String accountId) {
    try{
      String name = '%' + searchName + '%';
      return [SELECT Id, Name, Email, Phone, Photo_URL__c FROM Contact WHERE NAME LIKE :name WITH SECURITY_ENFORCED ORDER BY LastName, FirstName];
      // return [SELECT Id, Name, Email, Phone, Photo_URL__c FROM Contact WHERE NAME LIKE :name AND AccountId = :accountId WITH SECURITY_ENFORCED ORDER BY LastName, FirstName];
    } catch (Exception e){
      throw new AuraHandledException(e.getMessage());
    }
  }
  @AuraEnabled(cacheable=true)
  public static List<Contact> getContactProfile(String searchId) {
    try{
      String id = '%' + searchId + '%';
      return [SELECT Id, Name, Email, Phone, Title, Photo_URL__c FROM Contact WHERE Id = :searchId WITH SECURITY_ENFORCED ORDER BY LastName, FirstName];
    } catch (Exception e){
      throw new AuraHandledException(e.getMessage());
    }
  }  
}
