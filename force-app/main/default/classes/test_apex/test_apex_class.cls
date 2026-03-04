public with sharing class test_apex_class {
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(String accountName){
        try {
            return [SELECT id, Name FROM Account WHERE Name = :accountName LIMIT 5];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}