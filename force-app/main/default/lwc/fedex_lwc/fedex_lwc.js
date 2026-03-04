import { LightningElement, track } from 'lwc';
import getLatestScan from '@salesforce/apex/FedExTrackingService.getLatestScan';

export default class Fedex_lwc extends LightningElement {

    trackingNumber = '';
    @track latestScan;
    @track error;

    handleChange(event) {
        this.trackingNumber = event.target.value;
    }

    handleTrack() {
        this.error = undefined;
        this.latestScan = undefined;

        getLatestScan({ trackingNumber: this.trackingNumber })
            .then(result => {
                this.latestScan = result;
            })
            .catch(err => {
                this.error = err.body?.message || 'Unknown error';
            });
    }
}