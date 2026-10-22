# AirlinesManagementSystem (SkyManage)

Salesforce Lightning airline reservation application built with custom objects,
Apex, Lightning Web Components, validation rules, and source-driven deployment.

## Implemented modules

- Flight and flight schedule management
- Pilot and pilot schedule data model
- Passenger management
- Booking and PNR generation
- Case-insensitive duplicate-seat prevention
- Safe cancellation with record locking
- Mock payment processing without card or CVV storage
- Idempotent payment creation
- Flight search by route
- Booking Console with cancellation action
- Booking form with passenger details and flight selector
- Seat-map component with unavailable-seat styling
- Seat-map availability loaded from active Org bookings
- Airline analytics summary for bookings, cancellations, revenue, and payments
- Flight schedule duplicate protection trigger and mandatory schedule SOQL service
- Airlines Management Dashboard App Page metadata
- Apex tests for booking, payment, cancellation, seat validation, and flight search

## Data model

| Object | Purpose |
| --- | --- |
| `Flight__c` | Flight number/name and airline |
| `Flight_Schedule__c` | Route, departure, arrival, status, and pilots |
| `Pilot__c` | Pilot profile and experience |
| `Pilot_Schedule__c` | Pilot assignment to a schedule |
| `Passenger__c` | Passenger contact details |
| `Booking__c` | PNR, flight, passenger, seat, status, and amount |
| `Payment__c` | Booking payment amount and payment record |

`Booking__c` uses lookups to Flight and Passenger because a flight can have
many bookings and a passenger can book many flights. `Payment__c` uses a
master-detail relationship to Booking so payment history follows the booking.

## Main source locations

- Apex services and controllers: `force-app/main/default/classes`
- Seat trigger: `force-app/main/default/triggers/BookingSeatTrigger.trigger`
- Search UI: `force-app/main/default/lwc/flightSearch`
- Booking UI: `force-app/main/default/lwc/bookingForm`
- Seat UI: `force-app/main/default/lwc/seatMap`
- Booking Console UI: `force-app/main/default/lwc/bookingConsole`
- App page: `force-app/main/default/flexipages/Airlines_Management_Dashboard.flexipage-meta.xml`
- Demo data: `scripts/apex/create-demo-data.apex`
- Schedule trigger: `force-app/main/default/triggers/FlightScheduleTrigger.trigger`
- Schedule SOQL: `force-app/main/default/classes/FlightScheduleQueryService.cls`

## Deploy

From the project directory:

```powershell
sf project deploy start --target-org dev-org --source-dir force-app/main/default --wait 30
```

Run focused tests:

```powershell
sf apex run test --target-org dev-org --tests BookingSeatValidatorTest,BookingCancellationServiceTest,MockPaymentServiceTest,FlightSearchControllerTest,BookingWorkflowControllerTest,BookingConsoleControllerTest --result-format human --wait 30
```

Open the org:

```powershell
sf org open --target-org dev-org
```

## Activate the dashboard

In Salesforce:

1. Open **Setup → Lightning App Builder**.
2. Open **Airlines Management Dashboard**.
3. Save and activate the page.
4. Assign it to the `Airlines Management System` app.
5. Open the app and use Flight Search, Booking Form, Seat Map, and Booking Console.

## Safety rules

- No card numbers, CVVs, or secrets are stored.
- Booking seat validation ignores cancelled bookings so seats can be reused.
- Apex service classes use record locking where concurrent booking/payment/cancellation
  operations could conflict.
- Production payment processing requires an approved external payment gateway and
  should be implemented with Named Credentials rather than secrets in source.

## Demo data

The demo script creates fictional flights, passengers, bookings, pilots, schedules,
and payments. All email addresses use `example.com`.

```powershell
sf apex run --target-org dev-org --file scripts/apex/create-demo-data.apex
```

## Test coverage

The latest focused deployment verified:

- Booking workflow: 3 tests passed
- Flight search: 2 tests passed
- Booking Console: 2 tests passed
- Cancellation service: 3 tests passed
- Mock payment service: 3 tests passed
- Seat validator: previously verified with 3 tests passed
- Flight schedule trigger/SOQL: 4 tests passed

## Capstone implementation notes

The current Org has the schedule route and date/time fields available and the
duplicate active schedule trigger is deployed. The source package also contains
the planned status and pilot-assignment metadata, but the connected Org API
currently does not expose `Flight_Schedule__c.Status__c`,
`First_Pilot__c`, or `Second_Pilot__c`. Those fields must be created and
verified in the target Org before status automation, pilot-overlap validation,
pilot assignment emails, and schedule-status reports can be enabled safely.

The booking dashboard and analytics cards are implemented as Lightning
components. Native Salesforce Reports, dashboard chart metadata, Flow email
alerts, role hierarchy, public groups, and sharing rules still require Org
configuration before academic submission.

Before production use, add a CI job that deploys with `RunLocalTests`, enforces
CRUD/FLS review for every new controller, and configures approved notification
templates and a real payment integration.
