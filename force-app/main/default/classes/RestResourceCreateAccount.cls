@RestResource(urlMapping='/createAccount/*')
global with sharing class RestResourceCreateAccount {
    @HttpGet 
    global static void createAccountGET() {
        Map<String, Boolean> accountMap = new Map<String, Boolean>();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try{

            String accountName = req.params.get('name');

            if (accountName == null || String.isBlank(accountName)) {
                throw new RestException('Invalid Account Name.');
            }

            //check existing account
            List<Account> accountList = [SELECT Id FROM Account WHERE Name =: accountName LIMIT 1];
            
            if (accountList.size() > 0) {
                accountMap.put(accountName, false);
            } else {
                Account newAccount = new Account(Name = accountName);
                insert newAccount;
                accountMap.put(accountName, true);
            }
            //all fine now
            res.responseBody = generateRestResponse(accountMap);
            res.statusCode = 200;

        } catch (Exception e) {
            RestResponseError restResponse = new RestResponseError();
            restResponse.success = false;
            restResponse.error = e.getMessage();
            res.responseBody = Blob.valueOf(JSON.serialize(restResponse));
            res.statusCode = 400;
        }
        
    }

    @HttpPost 
    global static void createAccountPOST() {
        Map<String, Boolean> accountMap = new Map<String, Boolean>();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try{

            List<String> accountNameList = (List<String>) JSON.deserialize(RestContext.request.requestBody.toString(), List<String>.class);

            if (accountNameList.size() == 0) {
                throw new RestException('Invalid Account Name List.');
            }

            //check existing accounts
            List<Account> existingAccountList = [SELECT Id, Name FROM Account WHERE Name IN : accountNameList LIMIT 50000];
            Map<String, Id> existingAccountMap = new Map<String, Id>();
            for (Account account : existingAccountList) {
                existingAccountMap.put(account.Name, account.Id);
            }

            // init new account list
            List<Account> newAccountList = new List<Account>();

            for (String accountName : accountNameList) {
                if (existingAccountMap.containsKey(accountName)) {
                    accountMap.put(accountName, false);
                } else {
                    Account newAccount = new Account(Name = accountName);
                    newAccountList.add(newAccount);
                }
            }

            if (newAccountList.size() > 0) {
                Database.SaveResult[] accountSaveResultList = Database.insert(newAccountList, false);
                for (Database.SaveResult sr : accountSaveResultList) {
                    if (!sr.isSuccess()) {
                       // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                    } 
                }

                for (Account newAccount : newAccountList) {
                    accountMap.put(newAccount.Name, newAccount.Id != null);
                }
            }
            
            //all fine now
            res.responseBody = generateRestResponse(accountMap);
            res.statusCode = 200;

        } catch (Exception e) {
            RestResponseError restResponse = new RestResponseError();
            restResponse.success = false;
            restResponse.error = e.getMessage();
            res.responseBody = Blob.valueOf(JSON.serialize(restResponse));
            res.statusCode = 400;
        }
        
    }


    public static Blob generateRestResponse(Map<String, Boolean> accountMap) {
        JSONGenerator jsonObject = JSON.createGenerator(true);
        jsonObject.writeStartObject();
        for (String key : accountMap.keySet()) {
            jsonObject.writeBooleanField(key, accountMap.get(key));
        }
        jsonObject.writeEndObject();
        return Blob.valueOf(jsonObject.getAsString());
    }


    global class RestResponseError {
        Boolean success;
        String message;
        String error;
    }

    public class RestException extends Exception {}

    
}
