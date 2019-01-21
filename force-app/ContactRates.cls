public with sharing class ContactRates {

    public static sendContactRatesResult sendContactRates(Id contactId) {
        sendContactRatesResult result = new sendContactRatesResult();
        try {
            List<Contact> contactList = [SELECT Id, Send_Rate_Alerts__c, Name, FirstName, LastName, Email FROM Contact WHERE Id =: contactId LIMIT 1];
            if (contactList.size() == 0) {
                throw new AppException('Invalid Contact Id: ' + contactId);
            } 
            Contact contact = contactList[0];

            if (contact.Send_Rate_Alerts__c == false) {
                 throw new AppException('Contact : ' + contact.Name + ' does not accept rate alerts');
            }

            RestClient.RestResult restResult = RestClient.getNow('currencyRates','live?access_key=b5b6f6e947dc5026753055ec68d21db3&format=1');
            if (restResult.success == false) {
               throw new AppException('Cannot obtain live rates, please try again latter');
            }
            //all fine now
            ratesCLS ratesObject = (ratesCLS) JSON.deserialize(restResult.data, ratesCLS.class);
            sendEmailMessage(contact, ratesObject.quotes);

            result.success = true;
            result.message = 'Sent latest rates email to: ' + contact.Name;

        } catch (Exception e) {
            result.success = false;
            result.error = e.getMessage();
        }

        return result;
    }


    public static void sendEmailMessage(Contact contact, quoteCLS quoteObject) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {contact.Email}; 
		mail.setToAddresses(toAddresses);
		mail.setSubject('Latest Currency Rates');
		mail.setHtmlBody(buildRatesHtmlBody(quoteObject));
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    public static String buildRatesHtmlBody(quoteCLS quoteObject) {
        String htmlBody = '<html><head><style> body {font-family:verdana; font-size:13px;}</style></head><body>';
        htmlBody += '<table border="1" style="border-collapse: collapse"><tr><th>Code</th><th>Value</th></tr>';
        htmlBody += '<tr><td>USDCHF</td><td>'+quoteObject.USDCHF+'</td></tr>';
        htmlBody += '<tr><td>USDCAD</td><td>'+quoteObject.USDCAD+'</td></tr>';
        htmlBody += '<tr><td>USDEUR</td><td>'+quoteObject.USDEUR+'</td></tr>';
        htmlBody += '<tr><td>USDGBP</td><td>'+quoteObject.USDGBP+'</td></tr>';
        htmlBody += '<tr><td>USDIDR</td><td>'+quoteObject.USDIDR+'</td></tr>';
        htmlBody += '<tr><td>USDPLN</td><td>'+quoteObject.USDPLN+'</td></tr>';
        htmlBody += '</table>';
        htmlBody += '</body></html>';
        return htmlBody;
    }

    public class sendContactRatesResult {
        Boolean success;
        String message;
        String error;
    }


    public class ratesCLS {
        quoteCLS quotes;
    }

    public class quoteCLS {
        Double USDCHF;
        Double USDCAD;
        Double USDEUR;
        Double USDGBP;
        Double USDIDR; 
        Double USDPLN;
    }

    public class AppException extends Exception {}
}
