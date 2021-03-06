/**
 * Created by DDiaconescu on 19/11/2018.
 */

/**
* RestLogBuilderTest.cls
* Description: tests RestLogBuilder
**/
@isTest
private class RestLogBuilderTest {
    /**
    * @description tests successful log which does not get inserted as the log level is set to failure.
    */
    @isTest
    private static void it_should_return_SuccessLogRecord_NotInserted() {
        String expectedEndpoint = 'expectedEndpoint';
        String expectedRequestBody = 'expected request Body';
        String expectedResponseBody = 'expected request Body';

        Test.startTest();
        RestLogBuilder logBuilder = new RestLogBuilder();
        logBuilder.logLevel = RestLogBuilder.LOG_LEVEL_FAILURE;
        Rest_Log__c actualLog = logBuilder.withEndpoint(expectedEndpoint)
                .withRequestBody(expectedRequestBody)
                .withResponseBody(expectedResponseBody)
                .insertLog()
                .build();
        Test.stopTest();

        System.assertEquals(null, actualLog.Id); // NOT INSERTED AS LOG LEVEL IS FAILURE ONLY
        System.assertEquals(expectedEndpoint, actualLog.Endpoint__c);
        System.assertEquals(expectedRequestBody, actualLog.Request_Body__c);
        System.assertEquals(expectedResponseBody, actualLog.Response_Body__c);
        System.assertEquals(RestLogBuilder.STATUS_SUCCESS, actualLog.Status__c);
    }

    /**
    * @description tests successful log which does get inserted
    */
    @isTest
    private static void it_should_return_SuccessLogRecord_Inserted() {
        String expectedEndpoint = 'expectedEndpoint';
        String expectedRequestBody = 'expected request Body';
        String expectedResponseBody = 'expected request Body';

        Test.startTest();
        RestLogBuilder logBuilder = new RestLogBuilder();
        Rest_Log__c actualLog = logBuilder.withEndpoint(expectedEndpoint)
                .withRequestBody(expectedRequestBody)
                .withResponseBody(expectedResponseBody)
                .insertLog()
                .build();
        Test.stopTest();

        System.assertNotEquals(null, actualLog.Id);
        System.assertEquals(expectedEndpoint, actualLog.Endpoint__c);
        System.assertEquals(expectedRequestBody, actualLog.Request_Body__c);
        System.assertEquals(expectedResponseBody, actualLog.Response_Body__c);
        System.assertEquals(RestLogBuilder.STATUS_SUCCESS, actualLog.Status__c);
    }

    /**
    * @description tests failure log which gets inserted
    */
    @isTest
    private static void it_should_return_FailureLogRecord_Inserted() {
        String expectedEndpoint = 'expectedEndpoint';
        String expectedRequestBody = 'expected request Body';
        String expectedResponseBody = 'expected request Body';
        String expectedErrorCode = '400';
        String expectedExceptionText = 'expected exception message';
        JSONException expecedJsonEx = new JSONException(expectedExceptionText);

        Test.startTest();
        RestLogBuilder logBuilder = new RestLogBuilder();
        Rest_Log__c actualLog = logBuilder.withEndpoint(expectedEndpoint)
                .withRequestBody(expectedRequestBody)
                .withResponseBody(expectedResponseBody)
                .withErrorCode(expectedErrorCode)
                .withException(expecedJsonEx)
                .insertLog()
                .build();
        Test.stopTest();

        System.assertNotEquals(null, actualLog.Id);
        System.assertEquals(expectedEndpoint, actualLog.Endpoint__c);
        System.assertEquals(expectedRequestBody, actualLog.Request_Body__c);
        System.assertEquals(expectedResponseBody, actualLog.Response_Body__c);
        System.assertEquals(expectedResponseBody, actualLog.Response_Body__c);
        System.assertEquals(expectedErrorCode, actualLog.Error_Code__c);
        System.assertEquals(expectedExceptionText, actualLog.Message__c);
        System.assertEquals(RestLogBuilder.STATUS_FAILURE, actualLog.Status__c);
    }


    /**
    * @description tests successful log which does get queued to be inserted
    */
    @isTest
    private static void it_should_return_SuccessLogRecord_Queued() {
        String expectedEndpoint = 'expectedEndpoint';
        String expectedRequestBody = 'expected request Body';
        String expectedResponseBody = 'expected request Body';

        Test.startTest();
        RestLogBuilder logBuilder = new RestLogBuilder();
        Rest_Log__c actualLog = logBuilder.withEndpoint(expectedEndpoint)
                .withRequestBody(expectedRequestBody)
                .withResponseBody(expectedResponseBody)
                .queueLog()
                .build();
        Test.stopTest();

        actualLog = [SELECT Id, Endpoint__c, Request_Body__c, Response_Body__c, Status__c FROM Rest_Log__c LIMIT 1];
        System.assertNotEquals(null, actualLog.Id);
        System.assertEquals(expectedEndpoint, actualLog.Endpoint__c);
        System.assertEquals(expectedRequestBody, actualLog.Request_Body__c);
        System.assertEquals(expectedResponseBody, actualLog.Response_Body__c);
        System.assertEquals(RestLogBuilder.STATUS_SUCCESS, actualLog.Status__c);
    }

    /**
    * @description tests successful log which does get created via platform events
    */
    @isTest
    private static void it_should_return_SuccessLogRecord_Event() {
        String expectedMethod = 'POST';
        String expectedEndpoint = 'expectedEndpoint';
        String expectedRequestBody = 'expected request Body';
        String expectedResponseBody = 'expected request Body';

        Test.startTest();
        RestLogBuilder logBuilder = new RestLogBuilder();
        Rest_Log_Event__e actualLogEvent = logBuilder.withEndpoint(expectedEndpoint)
                .withMethod(expectedMethod)
                .withRequestBody(expectedRequestBody)
                .withResponseBody(expectedResponseBody)
                .withLogLevel('All')
                .withStartTime(system.now())
                .withEndTime(system.now())
                .eventLog()
                .buildEvent();
        Test.stopTest();

        Rest_Log__c actualLog = [SELECT Id, Method__c, Endpoint__c, Request_Body__c, Response_Body__c, Status__c FROM Rest_Log__c LIMIT 1];
        System.assertNotEquals(null, actualLog.Id);
        System.assertEquals(expectedMethod, actualLog.Method__c);
        System.assertEquals(expectedEndpoint, actualLog.Endpoint__c);
        System.assertEquals(expectedRequestBody, actualLog.Request_Body__c);
        System.assertEquals(expectedResponseBody, actualLog.Response_Body__c);
        System.assertEquals(RestLogBuilder.STATUS_SUCCESS, actualLog.Status__c);
    }

}