import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getAllFlights from '@salesforce/apex/AdminFlightController.getAllFlights';
import getFlightSchedules from '@salesforce/apex/AdminFlightController.getFlightSchedules';
import createFlight from '@salesforce/apex/AdminFlightController.createFlight';
import updateFlight from '@salesforce/apex/AdminFlightController.updateFlight';
import deleteFlight from '@salesforce/apex/AdminFlightController.deleteFlight';
import createFlightSchedule from '@salesforce/apex/AdminFlightController.createFlightSchedule';
import deleteFlightSchedule from '@salesforce/apex/AdminFlightController.deleteFlightSchedule';

const CITIES = [
    'Delhi', 'Mumbai', 'Pune', 'Bengaluru',
    'Kolkata', 'Chennai', 'Hyderabad'
];

const COMPANIES = [
    { label: 'IndiGo', value: 'IndiGo' },
    { label: 'Air India', value: 'Air India' },
    { label: 'GoAir', value: 'GoAir' },
    { label: 'Kingfisher', value: 'Kingfisher' }
];

const STATUS_OPTIONS = [
    { label: 'Scheduled', value: 'Scheduled' },
    { label: 'Delayed', value: 'Delayed' },
    { label: 'Cancelled', value: 'Cancelled' },
    { label: 'Completed', value: 'Completed' }
];

export default class AdminFlightManagement extends LightningElement {
    // Flight properties
    flightName = '';
    flightCompany = '';
    selectedFlightId = null;
    isEditMode = false;

    // Schedule properties
    showScheduleModal = false;
    scheduleSource = '';
    scheduleDestination = '';
    scheduleDeparture = '';
    scheduleArrival = '';
    scheduleFirstPilot = '';
    scheduleSecondPilot = '';
    scheduleStatus = 'Scheduled';

    @wire(getAllFlights)
    flights;

    @wire(getFlightSchedules, { flightId: '$selectedFlightId' })
    schedules;

    get companyOptions() {
        return COMPANIES;
    }

    get cityOptions() {
        return CITIES.map(city => ({ label: city, value: city }));
    }

    get statusOptions() {
        return STATUS_OPTIONS;
    }

    get formTitle() {
        return this.isEditMode ? 'Edit Flight' : 'New Flight';
    }

    get scheduleTitle() {
        return `Flight Schedules - ${this.selectedFlightName || ''}`;
    }

    get selectedFlightName() {
        if (!this.selectedFlightId || !this.flights.data) return '';
        const flight = this.flights.data.find(f => f.Id === this.selectedFlightId);
        return flight ? flight.Flight_Name__c : '';
    }

    flightColumns = [
        { label: 'Flight ID', fieldName: 'Name' },
        { label: 'Flight Name', fieldName: 'Flight_Name__c' },
        { label: 'Company', fieldName: 'Flight_Company__c' },
        {
            type: 'action',
            typeAttributes: {
                rowActions: [
                    { label: 'View Schedules', name: 'view_schedules' },
                    { label: 'Edit', name: 'edit' },
                    { label: 'Delete', name: 'delete' }
                ]
            }
        }
    ];

    scheduleColumns = [
        { label: 'Schedule ID', fieldName: 'Name' },
        { label: 'Source', fieldName: 'Source_Name__c' },
        { label: 'Destination', fieldName: 'Destination_Name__c' },
        {
            label: 'Departure',
            fieldName: 'Departure_Date_Time__c',
            type: 'date',
            typeAttributes: {
                year: 'numeric',
                month: 'short',
                day: '2-digit',
                hour: '2-digit',
                minute: '2-digit'
            }
        },
        {
            label: 'Arrival',
            fieldName: 'Arrival_Date_Time__c',
            type: 'date',
            typeAttributes: {
                year: 'numeric',
                month: 'short',
                day: '2-digit',
                hour: '2-digit',
                minute: '2-digit'
            }
        },
        { label: 'Status', fieldName: 'Status__c' },
        { label: 'First Pilot', fieldName: 'First_Pilot__c' },
        {
            type: 'action',
            typeAttributes: {
                rowActions: [
                    { label: 'Delete', name: 'delete' }
                ]
            }
        }
    ];

    handleFlightNameChange(event) {
        this.flightName = event.target.value;
    }

    handleFlightCompanyChange(event) {
        this.flightCompany = event.detail.value;
    }

    handleNewFlight() {
        this.flightName = '';
        this.flightCompany = '';
        this.selectedFlightId = null;
        this.isEditMode = false;
    }

    handleCancel() {
        this.handleNewFlight();
    }

    async handleSaveFlight() {
        if (!this.flightName || !this.flightCompany) {
            this.showToast('Error', 'Please fill all required fields', 'error');
            return;
        }

        try {
            if (this.isEditMode) {
                await updateFlight({
                    flightId: this.selectedFlightId,
                    flightName: this.flightName,
                    flightCompany: this.flightCompany
                });
                this.showToast('Success', 'Flight updated successfully', 'success');
            } else {
                await createFlight({
                    flightName: this.flightName,
                    flightCompany: this.flightCompany
                });
                this.showToast('Success', 'Flight created successfully', 'success');
            }

            this.handleNewFlight();
            return refreshApex(this.flights);
        } catch (error) {
            this.showToast('Error', error.body.message, 'error');
        }
    }

    handleFlightRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        switch (actionName) {
            case 'view_schedules':
                this.selectedFlightId = row.Id;
                break;
            case 'edit':
                this.selectedFlightId = row.Id;
                this.flightName = row.Flight_Name__c;
                this.flightCompany = row.Flight_Company__c;
                this.isEditMode = true;
                break;
            case 'delete':
                this.handleDeleteFlight(row.Id);
                break;
            default:
        }
    }

    async handleDeleteFlight(flightId) {
        if (!confirm('Are you sure you want to delete this flight?')) {
            return;
        }

        try {
            await deleteFlight({ flightId });
            this.showToast('Success', 'Flight deleted successfully', 'success');
            this.handleNewFlight();
            return refreshApex(this.flights);
        } catch (error) {
            this.showToast('Error', error.body.message, 'error');
        }
    }

    handleNewSchedule() {
        this.showScheduleModal = true;
        this.resetScheduleForm();
    }

    handleCloseScheduleModal() {
        this.showScheduleModal = false;
        this.resetScheduleForm();
    }

    resetScheduleForm() {
        this.scheduleSource = '';
        this.scheduleDestination = '';
        this.scheduleDeparture = '';
        this.scheduleArrival = '';
        this.scheduleFirstPilot = '';
        this.scheduleSecondPilot = '';
        this.scheduleStatus = 'Scheduled';
    }

    handleScheduleSourceChange(event) {
        this.scheduleSource = event.detail.value;
    }

    handleScheduleDestinationChange(event) {
        this.scheduleDestination = event.detail.value;
    }

    handleScheduleDepartureChange(event) {
        this.scheduleDeparture = event.target.value;
    }

    handleScheduleArrivalChange(event) {
        this.scheduleArrival = event.target.value;
    }

    handleScheduleFirstPilotChange(event) {
        this.scheduleFirstPilot = event.target.value;
    }

    handleScheduleSecondPilotChange(event) {
        this.scheduleSecondPilot = event.target.value;
    }

    handleScheduleStatusChange(event) {
        this.scheduleStatus = event.detail.value;
    }

    async handleSaveSchedule() {
        if (!this.scheduleSource || !this.scheduleDestination ||
            !this.scheduleDeparture || !this.scheduleArrival ||
            !this.scheduleFirstPilot || !this.scheduleStatus) {
            this.showToast('Error', 'Please fill all required fields', 'error');
            return;
        }

        try {
            await createFlightSchedule({
                flightId: this.selectedFlightId,
                source: this.scheduleSource,
                destination: this.scheduleDestination,
                departureTime: this.scheduleDeparture,
                arrivalTime: this.scheduleArrival,
                firstPilot: this.scheduleFirstPilot,
                secondPilot: this.scheduleSecondPilot,
                status: this.scheduleStatus
            });

            this.showToast('Success', 'Schedule created successfully', 'success');
            this.handleCloseScheduleModal();
            return refreshApex(this.schedules);
        } catch (error) {
            this.showToast('Error', error.body.message, 'error');
        }
    }

    handleScheduleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (actionName === 'delete') {
            this.handleDeleteSchedule(row.Id);
        }
    }

    async handleDeleteSchedule(scheduleId) {
        if (!confirm('Are you sure you want to delete this schedule?')) {
            return;
        }

        try {
            await deleteFlightSchedule({ scheduleId });
            this.showToast('Success', 'Schedule deleted successfully', 'success');
            return refreshApex(this.schedules);
        } catch (error) {
            this.showToast('Error', error.body.message, 'error');
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
