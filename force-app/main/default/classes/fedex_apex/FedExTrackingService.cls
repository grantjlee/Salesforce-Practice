public with sharing class FedExTrackingService {

    private static final String TRACK_ENDPOINT = 'callout:FedEx_API/track/v1/trackingnumbers';

    public static Map<String, Object> track(String trackingNumber) {

        String accessToken = FedExAuthService.getAccessToken();

        Map<String, Object> trackingNumberInfo = new Map<String, Object>{
            'trackingNumber' => trackingNumber,
            'carrierCode' => 'FDXE',
            'trackingNumberUniqueId' => 'placeholderUniqueId'
        };

        Map<String, Object> trackingInfoEntry = new Map<String, Object>{
            'shipDateBegin' => '2020-03-29',
            'shipDateEnd' => '2020-04-01',
            'trackingNumberInfo' => trackingNumberInfo
        };

        Map<String, Object> requestBody = new Map<String, Object>{
            'includeDetailedScans' => true,
            'trackingInfo' => new List<Object>{ trackingInfoEntry }
        };

        HttpRequest req = new HttpRequest();
        req.setEndpoint(TRACK_ENDPOINT);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(requestBody));

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            return (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        }

        throw new CalloutException('Tracking failed: ' + res.getBody());
    }

    @AuraEnabled(cacheable=false)
    public static Map<String, String> getLatestScan(String trackingNumber) {
        Map<String, Object> response = track(trackingNumber);

        List<Object> completeTrackResults = (List<Object>) ((Map<String, Object>) response.get('output')).get('completeTrackResults');
        if (completeTrackResults.isEmpty()) {
            return new Map<String, String>{ 'date' => '', 'description' => 'No tracking info' };
        }

        Map<String, Object> trackResult = (Map<String, Object>) completeTrackResults[0];
        List<Object> trackResultsList = (List<Object>) trackResult.get('trackResults');
        if (trackResultsList.isEmpty()) {
            return new Map<String, String>{ 'date' => '', 'description' => 'No tracking info' };
        }

        Map<String, Object> firstTrackResult = (Map<String, Object>) trackResultsList[0];
        List<Object> scanEvents = (List<Object>) firstTrackResult.get('scanEvents');
        if (scanEvents.isEmpty()) {
            return new Map<String, String>{ 'date' => '', 'description' => 'No scan events' };
        }

        Map<String, Object> latestScan = (Map<String, Object>) scanEvents.get(0);
        String inboundDate = (String) latestScan.get('date');
        String description = (String) latestScan.get('eventDescription');

        return new Map<String, String>{
            'date' => inboundDate,
            'description' => description
        };
    }
}