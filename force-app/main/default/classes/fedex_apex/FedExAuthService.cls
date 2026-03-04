public with sharing class FedExAuthService {

    private static final String TOKEN_ENDPOINT = 'callout:FedEx_API/oauth/token';

    public static String getAccessToken() {

        FedEx_Config__mdt cfg = [
            SELECT Client_ID__c, Client_Secret__c
            FROM FedEx_Config__mdt
            WHERE Environment__c = 'Sandbox, Production'
            LIMIT 1
        ];

        String clientId = cfg.Client_ID__c;
        String clientSecret = cfg.Client_Secret__c;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(TOKEN_ENDPOINT);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        String body = 'grant_type=client_credentials'
                    + '&client_id=' + EncodingUtil.urlEncode(clientId, 'UTF-8')
                    + '&client_secret=' + EncodingUtil.urlEncode(clientSecret, 'UTF-8');

        req.setBody(body);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            Map<String, Object> result =
                (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return (String) result.get('access_token');
        }

        throw new CalloutException('Failed to retrieve FedEx token: ' + res.getBody());
    }
}