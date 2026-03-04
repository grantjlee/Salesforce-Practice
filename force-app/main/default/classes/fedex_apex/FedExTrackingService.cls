public with sharing class FedExTrackingService {

    private static final String TRACK_ENDPOINT =
        'callout:FedEx_API/track/v1/trackingnumbers';

    public static Map<String, Object> track(String trackingNumber) {

        String accessToken = FedExAuthService.getAccessToken();

        HttpRequest req = new HttpRequest();
        req.setEndpoint(TRACK_ENDPOINT);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');

        Map<String, Object> requestBody = new Map<String, Object>{
            'trackingInfo' => new List<Object>{
                new Map<String, Object>{
                    'trackingNumberInfo' => new Map<String, String>{
                        'trackingNumber' => trackingNumber
                    }
                }
            },
            'includeDetailedScans' => true
        };

        req.setBody(JSON.serialize(requestBody));

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            return (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        }

        throw new CalloutException('Tracking failed: ' + res.getBody());
    }
}