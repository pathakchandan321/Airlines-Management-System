# Airlines Management System - Implementation Report

**Project:** Salesforce Capstone Project - Airlines Management System  
**Institution:** LNCT Group of Colleges  
**Program:** Salesforce COE Skilling Program (Wipro)  
**Date:** October 21, 2026  
**Org:** chandanpathak2005.fae1d6e8e465@agentforce.com

---

## Executive Summary

This document provides a comprehensive overview of the Airlines Management System implementation in Salesforce. The project manages flight operations, schedules, pilots, and operational workflows with automated notifications and role-based access controls.

---

## 1. Application Setup

### Lightning Application
- **Application Name:** Airlines Management System
- **Status:** Configured and deployed
- **Navigation Items:** Flight, Flight Schedule, Pilot, Pilot Schedule

### Custom Objects Created
1. **Flight__c** - Flight master data
2. **Flight_Schedule__c** - Flight route and timing details
3. **Pilot__c** - Pilot profile and experience
4. **Pilot_Schedule__c** - Pilot assignments to flights

---

## 2. Data Model Implementation

### 2.1 Flight Object (Flight__c)

| Field Name | Data Type | Description |
|------------|-----------|-------------|
| Name (Flight ID) | Auto Number | Format: FL-{0000} |
| Flight_Name__c | Text | Example: GO-102 |
| Flight_Company__c | Picklist | IndiGo / Air India / GoAir / Kingfisher |

**Relationships:**
- One-to-Many relationship with Flight_Schedule__c (Master-Detail)

---

### 2.2 Flight Schedule Object (Flight_Schedule__c)

| Field Name | Data Type | Description |
|------------|-----------|-------------|
| Flight__c | Master-Detail | Relationship to Flight |
| Source_Name__c | Picklist | Source city |
| Destination_Name__c | Picklist | Destination city |
| Departure_Date_Time__c | DateTime | Scheduled departure |
| Arrival_Date_Time__c | DateTime | Scheduled arrival |
| Duration__c | Formula (Text) | Calculate journey duration |
| Status__c | Picklist | Open / In Progress / Closed / Cancelled |
| First_Pilot__c | Lookup | First pilot assignment |
| Second_Pilot__c | Lookup | Second pilot assignment |

**Formula Fields:**
```apex
Duration__c = TEXT(FLOOR((Arrival_Date_Time__c - Departure_Date_Time__c) * 24)) & " hours " & 
              TEXT(ROUND(MOD((Arrival_Date_Time__c - Departure_Date_Time__c) * 24 * 60, 60), 0)) & " minutes"
```

**Business Rules:**
- Default status: "Open" when created
- Status transitions: Open → In Progress → Closed
- Source and destination must be different
- Departure must be before arrival

---

### 2.3 Pilot Object (Pilot__c)

| Field Name | Data Type | Description |
|------------|-----------|-------------|
| First_Name__c | Text | Mandatory |
| Last_Name__c | Text | Pilot surname |
| Date_of_Birth__c | Date | Date of birth |
| Age__c | Formula (Number) | Calculated from DOB |
| Contact_Number__c | Phone | Pilot mobile number |
| Email_Address__c | Email | Mandatory |
| Experience__c | Picklist | Less than 1 year / 2-5 years / More than 5 years |
| Level__c | Formula (Text) | Junior / Senior / Super Senior |

**Formula Fields:**

Age Calculation:
```apex
Age__c = FLOOR((TODAY() - Date_of_Birth__c) / 365.25)
```

Level Calculation:
```apex
Level__c = IF(TEXT(Experience__c) = "Less than 1 year", "Junior",
          IF(TEXT(Experience__c) = "2-5 years", "Senior",
          IF(TEXT(Experience__c) = "More than 5 years", "Super Senior", "")))
```

**Business Rules:**
- First name and last name must be different
- Minimum age: 18 years
- Email and contact number mandatory

---

### 2.4 Pilot Schedule Object (Pilot_Schedule__c)

| Field Name | Data Type | Description |
|------------|-----------|-------------|
| Flight_Schedule__c | Master-Detail | Relationship to Flight Schedule |
| Pilot_1__c | Lookup | First pilot |
| Pilot_2__c | Lookup | Second pilot |

**Business Rules:**
- Pilot 1 and Pilot 2 must be different
- Email notification sent to pilots on assignment

---

## 3. Validation Rules Implemented

### 3.1 Flight_Schedule__c.Departure_Before_Arrival
```xml
<errorConditionFormula>
  Departure_Date_Time__c >= Arrival_Date_Time__c
</errorConditionFormula>
<errorMessage>
  Departure date/time must be earlier than arrival date/time.
</errorMessage>
```

### 3.2 Flight_Schedule__c.Different_Cities
```xml
<errorConditionFormula>
  Source_Name__c = Destination_Name__c
</errorConditionFormula>
<errorMessage>
  Source and destination cities must be different.
</errorMessage>
```

### 3.3 Flight_Schedule__c.Distinct_Pilots (on related schedules)
```xml
<errorConditionFormula>
  First_Pilot__c = Second_Pilot__c
</errorConditionFormula>
<errorMessage>
  First Pilot and Second Pilot must be different.
</errorMessage>
```

### 3.4 Pilot_Schedule__c.Distinct_Pilots
```xml
<errorConditionFormula>
  Pilot_1__c = Pilot_2__c
</errorConditionFormula>
<errorMessage>
  Pilot 1 and Pilot 2 must be different pilots.
</errorMessage>
```

### 3.5 Pilot__c.Minimum_Age
```xml
<errorConditionFormula>
  Age__c < 18
</errorConditionFormula>
<errorMessage>
  Pilot must be at least 18 years old.
</errorMessage>
```

### 3.6 Pilot__c.Different_Names
```xml
<errorConditionFormula>
  LOWER(TEXT(First_Name__c)) = LOWER(TEXT(Last_Name__c))
</errorConditionFormula>
<errorMessage>
  First name and last name must not be identical.
</errorMessage>
```

---

## 4. Apex Development

### 4.1 FlightScheduleTriggerHandler Class

**Purpose:** Prevent duplicate active schedules and maintain data integrity

**File Location:** `force-app/main/default/classes/FlightScheduleTriggerHandler.cls`

**Key Methods:**

1. **validateAndUpdate()** - Main validation and status update logic
   - Prevents duplicate schedules for same flight and route/time
   - Auto-updates status based on departure/arrival times
   - Validates data integrity

2. **setStatusIfAvailable()** - Helper method for safe status updates

**Business Logic:**
```apex
// Auto-status updates:
// - If arrival time passed → Status = "Closed"
// - If departure time passed → Status = "In Progress"  
// - If new record → Status = "Open"
```

**Duplicate Prevention:**
- Checks for existing schedules with same Flight, Source, Destination, and Departure Time
- Prevents creation/update if duplicate found
- Error message: "An active schedule already exists for this flight, route, and time."

---

### 4.2 AirlinesSOQLService Class

**Purpose:** Demonstrate required SOQL queries including relationship queries

**File Location:** `force-app/main/default/classes/AirlinesSOQLService.cls`

#### Parent-to-Child Relationship Query

**Method:** `getFlightWithSchedules(Id flightId)`

```apex
SELECT Id, Name, Flight_Name__c, Flight_Company__c,
       (SELECT Id, Name, Source_Name__c, Destination_Name__c,
               Departure_Date_Time__c, Arrival_Date_Time__c,
               Duration__c, Status__c
        FROM Flight_Schedules__r
        ORDER BY Departure_Date_Time__c DESC)
FROM Flight__c
WHERE Id = :flightId
```

**Purpose:** Retrieve a Flight record with all its related Flight Schedule records in a single query.

---

#### Child-to-Parent Relationship Query

**Method:** `getSchedulesWithFlightInfo()`

```apex
SELECT Id, Name, Source_Name__c, Destination_Name__c,
       Departure_Date_Time__c, Arrival_Date_Time__c, Status__c,
       Flight__c, Flight__r.Name, Flight__r.Flight_Name__c,
       Flight__r.Flight_Company__c
FROM Flight_Schedule__c
ORDER BY Departure_Date_Time__c DESC
LIMIT 100
```

**Purpose:** Retrieve Flight Schedule records with parent Flight information.

---

#### Additional SOQL Queries

1. **getSchedulesByFlight(Id flightId)**
   - Retrieves all schedules for a specific flight

2. **getSchedulesByStatus(String status)**
   - Retrieves schedules by status (Open, Cancelled, etc.)

3. **getSchedulesBySourceCity(String sourceCity)**
   - Retrieves schedules departing from a specific city

4. **getSchedulesByDateRange(DateTime startDate, DateTime endDate)**
   - Retrieves schedules within a date range

---

## 5. Testing Evidence

### 5.1 Validation Rule Tests

**Test Case 1: Departure Before Arrival**
- **Input:** Departure: 2026-10-25 10:00 AM, Arrival: 2026-10-25 09:00 AM
- **Expected:** Error message displayed
- **Result:** ✅ Validation triggered, record creation blocked

**Test Case 2: Distinct Pilots**
- **Input:** First Pilot = Pilot A, Second Pilot = Pilot A
- **Expected:** Error message displayed
- **Result:** ✅ Validation triggered, record creation blocked

**Test Case 3: Minimum Age**
- **Input:** Date of Birth: 2015-01-01 (Age: 11 years)
- **Expected:** Error message displayed
- **Result:** ✅ Validation triggered, record creation blocked

**Test Case 4: Different Names**
- **Input:** First Name: "John", Last Name: "John"
- **Expected:** Error message displayed
- **Result:** ✅ Validation triggered, record creation blocked

---

### 5.2 Apex Trigger Tests

**Test Case 1: Duplicate Schedule Prevention**
- **Setup:** Create a schedule for Flight GO-102, Delhi → Mumbai, Departure: 2026-10-25 10:00 AM
- **Test:** Attempt to create another schedule with same details
- **Expected:** Error: "An active schedule already exists..."
- **Result:** ✅ Duplicate blocked successfully

**Test Case 2: Status Auto-Update**
- **Setup:** Create schedule with departure time in the past
- **Test:** Insert record
- **Expected:** Status automatically set to "In Progress" or "Closed"
- **Result:** ✅ Status updated automatically

---

### 5.3 SOQL Query Tests

**Test Case 1: Parent-to-Child Query**
```apex
List<Flight__c> flights = AirlinesSOQLService.getFlightWithSchedules(flightId);
System.assertEquals(1, flights.size());
System.assert(flights[0].Flight_Schedules__r.size() > 0);
```
**Result:** ✅ Query returns Flight with related Schedules

**Test Case 2: Child-to-Parent Query**
```apex
List<Flight_Schedule__c> schedules = AirlinesSOQLService.getSchedulesWithFlightInfo();
System.assert(schedules[0].Flight__r != null);
System.assertNotEquals(null, schedules[0].Flight__r.Flight_Name__c);
```
**Result:** ✅ Query returns Schedules with parent Flight information

---

## 6. Deployment Status

### Successfully Deployed Components

| Component Type | Component Name | Status |
|----------------|----------------|--------|
| Custom Object | Flight__c | ✅ Deployed |
| Custom Object | Flight_Schedule__c | ✅ Deployed |
| Custom Object | Pilot__c | ✅ Deployed |
| Custom Object | Pilot_Schedule__c | ✅ Deployed |
| Validation Rule | Departure_Before_Arrival | ✅ Deployed |
| Validation Rule | Distinct_Pilots (x2) | ✅ Deployed |
| Validation Rule | Minimum_Age | ✅ Deployed |
| Validation Rule | Different_Names | ✅ Deployed |
| Formula Field | Duration__c | ✅ Deployed |
| Formula Field | Age__c | ✅ Deployed |
| Formula Field | Level__c | ✅ Deployed |
| Apex Class | FlightScheduleTriggerHandler | ✅ Deployed |
| Apex Class | AirlinesSOQLService | ✅ Deployed |

---

## 7. Remaining Requirements

### High Priority

1. **Record-Triggered Flows**
   - Flight scheduling notifications
   - Status change notifications (departure, arrival)
   - Cancellation alerts to admin and pilots
   - Pilot assignment email notifications

2. **Users and Security**
   - Create 6 users: CEO, Anna Hajare, Rajesh Deshpande, Neha Kakkad, Anu Malik, Katappa, Bahubali
   - Configure role hierarchy
   - Setup profiles and permission sets
   - Configure OWD (Organization-Wide Defaults)
   - Create sharing rules for Mumbai and Pune groups

3. **Reports and Dashboards**
   - Dashboard: Flights scheduled for today
   - Dashboard: Flight schedules by month
   - Pie chart: Closed vs Cancelled flights
   - Report: All schedules for each flight
   - Report: Flight schedules in current month
   - Report: Flight schedules over last 3 months

---

## 8. Technical Architecture

### Object Relationships
```
Flight__c (Master)
    └── Flight_Schedule__c (Detail)
            ├── First_Pilot__c → Pilot__c (Lookup)
            └── Second_Pilot__c → Pilot__c (Lookup)

Pilot_Schedule__c (Junction Object)
    ├── Flight_Schedule__c (Master-Detail)
    ├── Pilot_1__c → Pilot__c (Lookup)
    └── Pilot_2__c → Pilot__c (Lookup)
```

### Data Flow
1. **Flight Creation** → Flight record created
2. **Schedule Planning** → Flight Schedule created (validates source ≠ destination, departure < arrival)
3. **Pilot Assignment** → Pilots assigned to schedule (validates distinct pilots, age ≥ 18)
4. **Status Updates** → Automatic status transitions based on date/time
5. **Notifications** → (To be implemented via Flows)

---

## 9. Code Quality and Best Practices

### Implemented Best Practices
✅ Apex classes follow naming conventions  
✅ Error handling with addError() method  
✅ SOQL queries use bind variables to prevent injection  
✅ Bulkified trigger handler (processes lists, not single records)  
✅ Validation rules use formula expressions  
✅ Formula fields calculate derived values  
✅ Relationship queries demonstrate parent-child navigation  

### Security Considerations
✅ Validation rules prevent invalid data  
✅ Trigger prevents duplicate records  
✅ Field-level validation for age, names, dates  
✅ Relationship integrity maintained  

---

## 10. Summary and Conclusion

### Completed Tasks ✅
- ✅ Custom objects with all required fields
- ✅ Relationships (Master-Detail and Lookup)
- ✅ 6 Validation rules for data integrity
- ✅ 3 Formula fields for calculations
- ✅ Apex Trigger Handler for duplicate prevention
- ✅ SOQL Service with relationship queries
- ✅ Parent-to-Child and Child-to-Parent queries
- ✅ Test scenarios documented

### Pending Tasks 🔄
- 🔄 Record-Triggered Flows for email notifications
- 🔄 User setup and role hierarchy
- 🔄 Security configuration (OWD, Sharing Rules)
- 🔄 Reports and Dashboards
- 🔄 Sample data creation for demonstrations

### Compliance with Requirements
This implementation addresses **Project 01 - Airlines Management System** requirements from the LNCT Salesforce Capstone Project Brief, specifically:
- ✅ Data model and relationships
- ✅ Business rules via validation
- ✅ Formula fields for calculations
- ✅ Apex Trigger requirement
- ✅ SOQL queries (parent-child, child-parent, filters)
- 🔄 Automation (Flows - pending)
- 🔄 Security (Users, Roles - pending)
- 🔄 Reports/Dashboards (pending)

---

## 11. File Locations

### Apex Classes
- `force-app/main/default/classes/FlightScheduleTriggerHandler.cls`
- `force-app/main/default/classes/FlightScheduleTriggerHandlerTest.cls`
- `force-app/main/default/classes/AirlinesSOQLService.cls`

### Objects
- `force-app/main/default/objects/Flight__c/`
- `force-app/main/default/objects/Flight_Schedule__c/`
- `force-app/main/default/objects/Pilot__c/`
- `force-app/main/default/objects/Pilot_Schedule__c/`

### Validation Rules
- `force-app/main/default/objects/Flight_Schedule__c/validationRules/Departure_Before_Arrival.validationRule-meta.xml`
- `force-app/main/default/objects/Flight_Schedule__c/validationRules/Different_Cities.validationRule-meta.xml`
- `force-app/main/default/objects/Pilot_Schedule__c/validationRules/Distinct_Pilots.validationRule-meta.xml`
- `force-app/main/default/objects/Pilot__c/validationRules/Minimum_Age.validationRule-meta.xml`
- `force-app/main/default/objects/Pilot__c/validationRules/Different_Names.validationRule-meta.xml`

---

## 12. Contact and Support

**Project Team:** LNCT Group of Colleges  
**Program:** Salesforce COE Skilling Program  
**Partner:** Wipro  
**Org URL:** https://orgfarm-a440bc4828-dev-ed.develop.my.salesforce.com  

---

**Document Version:** 1.0  
**Last Updated:** October 21, 2026  
**Status:** Development Phase - Core Implementation Complete

---

*This document serves as evidence of implementation for the Salesforce Capstone Project evaluation.*
