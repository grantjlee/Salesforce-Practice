public with sharing class FedExAuthService {

    private static final String TOKEN_ENDPOINT = 'callout:FedEx_API/oauth/token';

    public static String getAccessToken() {

        HttpRequest req = new HttpRequest();
        req.setEndpoint(TOKEN_ENDPOINT);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        String clientId = 'YOUR_CLIENT_ID';
        String clientSecret = 'YOUR_CLIENT_SECRET';

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