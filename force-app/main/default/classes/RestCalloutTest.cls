/**
 * Created by DDiaconescu on 19/11/2018.
 */

/**
* RestCalloutTest.cls
* Description: Test class for RestCallout
**/
@isTest
private class RestCalloutTest {
    /**
    * @description tests httpRequest is initiated on constructing the RestCallout class
    */
    @isTest private static void it_should_InstantiateWithDefaultHeaders() {
        Test.startTest();
        RestCallout actualRestCallout = new RestCallout();
        Test.stopTest();

        System.assertNotEquals(null, actualRestCallout.httpRequest);
        System.assertEquals('application/json', actualRestCallout.httpRequest.getHeader('Content-Type'));
    }

    /**
    * @description tests setting the method for the httpRequest
    */
    @isTest private static void it_should_SetTheMethod() {
        String expectedMethod = 'GET';
        RestCallout actualRestCallout = new RestCallout();

        Test.startTest();
        actualRestCallout.setMethod(expectedMethod);
        Test.stopTest();

        System.assertEquals(expectedMethod, actualRestCallout.httpRequest.getMethod());
    }

    /**
    * @description tests setting the endpoint for the httpRequest
    */
    @isTest private static void it_should_SetTheEndpoint() {
        String expectedEndpoint = 'endpoint';
        RestCallout actualRestCallout = new RestCallout();

        Test.startTest();
        actualRestCallout.setEndpoint(expectedEndpoint);
        Test.stopTest();

        System.assertEquals(expectedEndpoint, actualRestCallout.httpRequest.getEndpoint());
    }

    /**
    * @description tests setting the endpoint via named credential for the httpRequest
    */
    @isTest private static void it_should_SetTheEndpointViaNamedCredential() {
        String expectedEndpoint = 'endpoint';
        String expectedPath = 'path';
        RestCallout actualRestCallout = new RestCallout();

        Test.startTest();
        actualRestCallout.setNamedCredential(expectedEndpoint, expectedPath);
        Test.stopTest();

        System.assertEquals('callout:' + expectedEndpoint + '/' + expectedPath, actualRestCallout.httpRequest.getEndpoint());
    }

    /**
    * @description tests setting the client certificate for the httpRequest
    */
    /* TODO: replace <certName> with an existing certificate in our org
    @isTest private static void it_should_SetTheClientCertificate() {
        RestCallout actualRestCallout = new RestCallout();

        Test.startTest();
            actualRestCallout.setClientCertificate('<certName>');
        Test.stopTest();

        // TODO: cannot assert certificate is set...
        System.assertNotEquals(null, actualRestCallout.httpRequest);
        System.assertEquals('application/json', actualRestCallout.httpRequest.getHeader('Content-Type'));
    }*/

    /**
    * @description tests setting the timeout for the httpRequest
    */
    @isTest private static void it_should_SetTheTimeOut() {
        RestCallout actualRestCallout = new RestCallout();

        Test.startTest();
        actualRestCallout.setTimeout(1);
        Test.stopTest();

        // TODO: cannot assert timeout is set...
        System.assertNotEquals(null, actualRestCallout.httpRequest);
        System.assertEquals('application/json', actualRestCallout.httpRequest.getHeader('Content-Type'));
    }

    /**
    * @description tests setting the header for the httpRequest
    */
    @isTest private static void it_should_SetAHeader() {
        String expectedHeaderName = 'headerName';
        String expectedHeaderValue = 'headerValue';
        RestCallout actualRestCallout = new RestCallout();

        Test.startTest();
        actualRestCallout.setHeader(expectedHeaderName, expectedHeaderValue);
        Test.stopTest();

        System.assertNotEquals(null, actualRestCallout.httpRequest.getHeader(expectedHeaderName));
        System.assertEquals(expectedHeaderValue, actualRestCallout.httpRequest.getHeader(expectedHeaderName));
    }

    /**
    * @description tests setting the body for the httpRequest
    */
    @isTest private static void it_should_SetTheBody() {
        String expectedBody = 'body';
        RestCallout actualRestCallout = new RestCallout();

        Test.startTest();
        actualRestCallout.setBody(expectedBody);
        Test.stopTest();

        System.assertEquals(expectedBody, actualRestCallout.httpRequest.getBody());
    }

    /**
    * @description tests making a successful callout
    */
    @isTest private static void it_should_DoACalloutWithReturnedSuccess() {
        RestCallout actualRestCallout = new RestCallout();
        String expectedResponseBody = 'success body';
        RestMock responseMock = new RestMock(
                200,
                RestLogBuilder.STATUS_SUCCESS,
                expectedResponseBody,
                new Map<String, String>()
        );
        Test.setMock(HttpCalloutMock.class, responseMock);

        Test.startTest();
        actualRestCallout.call();
        HttpResponse actualResponse = actualRestCallout.httpResponse;
        String actualResponseBody = actualResponse.getBody();
        Test.stopTest();

        System.assertEquals(expectedResponseBody, actualResponseBody);
    }

    /**
    * @description tests making a failed callout
    */
    @isTest private static void it_should_DoACalloutWithReturnedFailure() {
        RestCallout actualRestCallout = new RestCallout();
        Integer expectedResponseStatus = 400;
        String expectedResponseBody = 'failure body';
        RestMock responseMock = new RestMock(
                expectedResponseStatus,
                RestLogBuilder.STATUS_FAILURE,
                expectedResponseBody,
                new Map<String, String>()
        );
        Test.setMock(HttpCalloutMock.class, responseMock);

        Test.startTest();
        actualRestCallout.call();
        HttpResponse httpResponse = actualRestCallout.httpResponse;
        Test.stopTest();

        System.assertEquals(httpResponse.getStatusCode(), expectedResponseStatus);
        System.assertEquals(httpResponse.getBody(), expectedResponseBody);

    }
}