@isTest
public class TestUtils {

    public static User createUser() {
        // Create a unique UserName
        String randomString = TestUtils.generateRandomString(8);
        String uniqueUserName = randomString + DateTime.now().getTime() + '@' + randomString + '.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = randomString, Email = uniqueUserName,
                EmailEncodingKey = 'UTF-8', LastName = randomString, LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles',
                UserName = uniqueUserName);
        insert u;
        return u;
    }

    public static Account createAccount(){
        Account newAccount = new Account();
        newAccount.Name = generateRandomString(8);
        insert newAccount;
        return newAccount;
    }

    public static Case createCase(){
        Case newCase = new Case();
        newCase.Subject = generateRandomString(8);
        insert newCase;
        return newCase;
    }

    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = getRandomInt(0, chars.length() - 1);
            randStr += chars.substring(idx, idx + 1);
        }
        return randStr;
    }

    public static String generateRandomNumber(Integer len) {
        final String chars = '01234567890123456789012345678901234567890123456789012345678901234567890123456789';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = getRandomInt(0, chars.length() - 1);
            randStr += chars.substring(idx, idx + 1);
        }
        return randStr;
    }

    public static Integer getRandomInt(Integer lower, Integer upper) {
        return Math.round(Math.random() * (upper - lower)) + lower;
    }
}