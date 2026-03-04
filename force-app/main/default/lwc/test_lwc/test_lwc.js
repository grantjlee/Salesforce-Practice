import { LightningElement, api, track, wire } from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import FIRST_NAME from '@salesforce/schema/User.FirstName';
import EMAIL from '@salesforce/schema/User.Email';
import GET_ACCOUNTS from '@salesforce/apex/test_apex_class.getAccounts';

const FIELDS = [FIRST_NAME, EMAIL];

export default class Test_lwc extends LightningElement {

    @api recordId;
    @api objectApiName;
    headerText = "This is a header text sample";
    userId = Id;
    @track exampleObject = {};

    @wire(getRecord, {recordId: '$userId', fields: FIELDS})
    user;

    get firstName() {
        return getFieldValue(this.user.data, FIRST_NAME);
    }

    get email() {
        return getFieldValue(this.user.data, EMAIL);
    }

    async getAccounts(){
        await GET_ACCOUNTS({accountName: 'Test Account'})
            .then(result => {
                this.accountRecords = result;
                console.log("These are the account records: " + JSON.stringify(this.accountRecords));
            })
            .catch(error => {
                console.log('Error: ::: + ' + error);
            });
    }

    changeUserId() {
        this.userId = '005fj00000DMDAPAA5';
    }

    method1() {
        this.methodName(this.userId, FIELDS);
    }

    method(){
        this.headerText = "Different Text"
    }

}