public with sharing class FedExTrackingController {

    @AuraEnabled
    public static Map<String, Object> trackPackage(String trackingNumber) {
        return FedExTrackingService.track(trackingNumber);
    }
}