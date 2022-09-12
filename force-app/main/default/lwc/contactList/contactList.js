import { LightningElement, wire, api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getContacts from '@salesforce/apex/ContactSearchController.getContacts';
import getContactProfile from '@salesforce/apex/ContactSearchController.getContactProfile';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
  { label: "Name", fieldName: "Name" },
  { label: "Email", fieldName: "Email", type: "Email" },
  { label: "Phone", fieldName: "Phone", type: "phone" }
];

export default class ContactList extends NavigationMixin(LightningElement) {
  @api recordId;
  columns = columns;
  searchValue;
  contacts;
  showNewForm;
  newContact = {};
  placeholderPhoto = 'https://180dc.org/wp-content/uploads/2017/11/profile-placeholder.png';
  @track selected = false;
  @track profile = {};
  @track contactUrl;
  @track url;

  searchHandler(event) {
    this.searchValue = event.target.value;
    if (this.searchValue.length >= 3)
      this.getData();
  }

  getData() {
    getContacts({ searchName: this.searchValue, accountId: this.recordId })
      .then((result) => {
        this.contacts = result;
      }).catch((error) => {
        console.log('There was an error retrieving the data', error);
      })
  }

  showData(evet) {
    let row = this.template.querySelector("lightning-datatable").getSelectedRows()[0];
    this.profile = {}
    this.showProfileData(row.Id);
  }

  showProfileData(id) {
    this.profile = {}
    getContactProfile({ searchId: id })
      .then((result) => {
        this.selected = true;
        this.profile.Id = result[0].Id;
        this.profile.Photo = result[0].Photo_URL__c ? result[0].Photo_URL__c : this.placeholderPhoto;
        this.profile.Name = result[0].Name;
        this.profile.Role = result[0].Title ? result[0].Title : 'N/A';
        this.profile.Phone = result[0].Phone ? result[0].Phone : 'N/A';
        this.profile.Email = result[0].Email ? result[0].Email : 'N/A';
        this.profile.Description = this.profile.Role + " - " + this.profile.Phone + " - " + this.profile.Email;

        this[NavigationMixin.GenerateUrl]({
          type: 'standard__recordPage',
          attributes: {
            recordId: result[0].Id,
            actionName: 'view',
          },
        }).then((url) => {
          this.url = url;
        });

      }).catch((error) => {
        console.log('There was an error retrieving the data', error);
      })
  }

  toggleNewForm() {
    this.showNewForm = !this.showNewForm;
  }

  createNewContact() {
    let fields = { AccountId: this.recordId, FirstName: this.newContact.firstName, LastName: this.newContact.lastName, Email: this.newContact.email, Phone: this.newContact.phone, Title: this.newContact.role };
    let objRecordInput = { 'apiName': 'Contact', fields };
    createRecord(objRecordInput).then(response => {
      console.log('Concat created with Id: ' + response.id);
      const evt = new ShowToastEvent({
        title: 'Concat created succesfully',
        message: 'Concat created with Id: ' + response.id,
        variant: 'Success',
      });
      this.dispatchEvent(evt);
    }).catch(error => {
      const evt = new ShowToastEvent({
        title: 'Concat creation failed',
        message: 'There was an error creating the contact, please check your data',
        variant: 'Error',
      });
      this.dispatchEvent(evt);
      console.log('There was an error creating the contact. Please show this to your admin: ' + JSON.stringify(error));
    });
    this.newContact = {};
  }

  handleFieldChange(event) {
    switch (event.target.label) {
      case 'FirstName':
        this.newContact.firstName = event.target.value;
        break;
      case 'LastName':
        this.newContact.lastName = event.target.value;
        break;
      case 'Role':
        this.newContact.role = event.target.value;
        break;
      case 'Email':
        this.newContact.email = event.target.value;
        break;
      case 'Phone':
        this.newContact.phone = event.target.value;
        break;
      default:
        break;
    }
  }

}
