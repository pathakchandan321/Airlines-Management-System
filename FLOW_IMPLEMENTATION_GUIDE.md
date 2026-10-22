# Record-Triggered Flows - Implementation Guide
## Airlines Management System

**Date:** October 21, 2026, 5:15 PM  
**Status:** Ready to Implement

---

## 🔔 **Required Flows (4 Total)**

### Flow 1: Flight Schedule Created - Send Notification
### Flow 2: Flight Status Changed to In Progress - Departure Alert
### Flow 3: Flight Status Changed to Cancelled - Cancellation Alert  
### Flow 4: Pilot Assignment - Email to Pilots

---

## 📋 **FLOW 1: Flight Schedule Created Notification**

### Manual Steps (Salesforce UI):

**Step 1: Create New Flow**
1. Setup → Flows → New Flow
2. Select: **Record-Triggered Flow**
3. Click **Create**

**Step 2: Configure Trigger**
```
Object: Flight_Schedule__c
Trigger: A record is created
Entry Conditions: None (run for all new records)
Optimize For: Actions and Related Records
```

**Step 3: Add Action - Send Email**
```
Action: Send Email
Label: Notify Admin of New Schedule
Description: Send email when schedule created

Recipients:
- To: [System Administrator Email]
  
Email Alert:
- Subject: New Flight Schedule: {!$Record.Name}
- Body (Plain Text):
  Flight Schedule Created
  
  Flight Name: {!$Record.Flight__r.Flight_Name__c}
  Route: {!$Record.Source_Name__c} to {!$Record.Destination_Name__c}
  Departure: {!$Record.Departure_Date_Time__c}
  Arrival: {!$Record.Arrival_Date_Time__c}
  Status: {!$Record.Status__c}
  
  View Record: [Link]
```

**Step 4: Activate Flow**
- Click **Save**
- Name: `Flight_Schedule_Created_Notification`
- API Name: `Flight_Schedule_Created_Notification`
- Click **Activate**

---

## 📋 **FLOW 2: Flight Departure Notification**

### Manual Steps:

**Step 1: Create New Flow**
1. Setup → Flows → New Flow
2. Select: **Record-Triggered Flow**

**Step 2: Configure Trigger**
```
Object: Flight_Schedule__c
Trigger: A record is updated
Entry Conditions:
  - [Status__c] [Is Changed] [True]
  - AND
  - [Status__c] [Equals] [In Progress]
```

**Step 3: Add Action - Send Email**
```
Label: Notify Departure
Recipients: System Administrator

Email Body:
Flight Departing Now!

Flight: {!$Record.Flight__r.Flight_Name__c}
Route: {!$Record.Source_Name__c} → {!$Record.Destination_Name__c}
Departure: {!$Record.Departure_Date_Time__c}
Status: In Progress

Pilots Assigned:
- First Pilot: {!$Record.First_Pilot__r.Name}
- Second Pilot: {!$Record.Second_Pilot__r.Name}
```

**Step 4: Save & Activate**
- Name: `Flight_Departure_Notification`
- Activate

---

## 📋 **FLOW 3: Flight Cancellation Alert**

### Manual Steps:

**Step 1: Create Record-Triggered Flow**
```
Object: Flight_Schedule__c
Trigger: A record is updated
Entry Conditions:
  - [Status__c] [Is Changed] [True]
  - AND
  - [Status__c] [Equals] [Cancelled]
```

**Step 2: Add Multiple Actions**

**Action 1: Email to Admin**
```
Label: Notify Admin of Cancellation
To: System Administrator
Subject: URGENT: Flight Cancelled - {!$Record.Name}

Body:
FLIGHT CANCELLATION ALERT

Flight: {!$Record.Flight__r.Flight_Name__c}
Route: {!$Record.Source_Name__c} to {!$Record.Destination_Name__c}
Originally Scheduled: {!$Record.Departure_Date_Time__c}

Action Required: Contact pilots and arrange alternate schedule.
```

**Action 2: Email to First Pilot** (If assigned)
```
Label: Notify First Pilot
Condition: {!$Record.First_Pilot__c} [Is Null] [False]

To: {!$Record.First_Pilot__r.Email_Address__c}
Subject: Flight Cancelled - {!$Record.Name}

Body:
Dear {!$Record.First_Pilot__r.First_Name__c},

Your assigned flight has been cancelled:

Flight: {!$Record.Flight__r.Flight_Name__c}
Route: {!$Record.Source_Name__c} to {!$Record.Destination_Name__c}
Originally Scheduled: {!$Record.Departure_Date_Time__c}

Please contact operations for further instructions.

Airlines Management System
```

**Action 3: Email to Second Pilot** (If assigned)
```
Similar to Action 2, but for Second Pilot
```

**Step 3: Save & Activate**
- Name: `Flight_Cancellation_Alert`

---

## 📋 **FLOW 4: Pilot Assignment Notification**

### Manual Steps:

**Step 1: Create Record-Triggered Flow**
```
Object: Flight_Schedule__c
Trigger: A record is created or updated
Entry Conditions:
  - [First_Pilot__c] [Is Changed] [True]
  - OR
  - [Second_Pilot__c] [Is Changed] [True]
```

**Step 2: Decision Element - Check Which Pilot Changed**

**Decision 1: First Pilot Assigned?**
```
Condition: {!$Record.First_Pilot__c} [Is Null] [False]
AND
Previous First Pilot was different
```

**Outcome 1 Actions:**
```
Send Email to First Pilot:
To: {!$Record.First_Pilot__r.Email_Address__c}
Subject: Flight Assignment - {!$Record.Name}

Body:
Dear {!$Record.First_Pilot__r.First_Name__c} {!$Record.First_Pilot__r.Last_Name__c},

You have been assigned as First Pilot for:

Flight Name: {!$Record.Flight__r.Flight_Name__c}
Company: {!$Record.Flight__r.Flight_Company__c}
Route: {!$Record.Source_Name__c} → {!$Record.Destination_Name__c}

Departure: {!$Record.Departure_Date_Time__c}
Arrival: {!$Record.Arrival_Date_Time__c}
Duration: {!$Record.Duration__c}

Co-Pilot: {!$Record.Second_Pilot__r.Name}

Please confirm your availability.

Best regards,
Airlines Management System
```

**Decision 2: Second Pilot Assigned?**
```
Similar logic for Second Pilot
```

**Step 3: Save & Activate**
- Name: `Pilot_Assignment_Notification`

---

## ⚡ **QUICK IMPLEMENTATION (Alternative - Use Process Builder)**

Agar Flows complex lag rahe hain, toh **Workflow Rules** ya **Process Builder** se bhi kar sakte ho:

### Using Process Builder:

**Process 1: Schedule Created**
```
1. Setup → Process Builder → New Process
2. Object: Flight_Schedule__c
3. When: Record is created
4. Action: Email Alert
5. Activate
```

---

## 🚀 **AUTOMATED DEPLOYMENT (Advanced)**

Agar manually nahi karna toh main **Flow metadata files** bhi create kar sakta hoon, but yeh thoda complex hai.

### Alternative: Use Apex Email Alerts

Main ek simple **Apex Trigger** bana deta hoon jo emails send kare:

```apex
trigger FlightScheduleEmailTrigger on Flight_Schedule__c (after insert, after update) {
    
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    
    for (Flight_Schedule__c schedule : Trigger.new) {
        
        // Email on Creation
        if (Trigger.isInsert) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[]{'admin@yourdomain.com'});
            email.setSubject('New Flight Schedule: ' + schedule.Name);
            email.setPlainTextBody(
                'Flight Schedule Created\n\n' +
                'Schedule: ' + schedule.Name + '\n' +
                'Status: ' + schedule.Status__c + '\n' +
                'Source: ' + schedule.Source_Name__c + '\n' +
                'Destination: ' + schedule.Destination_Name__c
            );
            emails.add(email);
        }
        
        // Email on Status Change to Cancelled
        if (Trigger.isUpdate) {
            Flight_Schedule__c oldSchedule = Trigger.oldMap.get(schedule.Id);
            
            if (schedule.Status__c == 'Cancelled' && 
                oldSchedule.Status__c != 'Cancelled') {
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[]{'admin@yourdomain.com'});
                email.setSubject('CANCELLED: Flight ' + schedule.Name);
                email.setPlainTextBody(
                    'FLIGHT CANCELLATION ALERT\n\n' +
                    'Schedule: ' + schedule.Name + '\n' +
                    'Status: CANCELLED\n' +
                    'Route: ' + schedule.Source_Name__c + ' to ' + schedule.Destination_Name__c
                );
                emails.add(email);
            }
            
            // Email on Status Change to In Progress
            if (schedule.Status__c == 'In Progress' && 
                oldSchedule.Status__c != 'In Progress') {
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[]{'admin@yourdomain.com'});
                email.setSubject('Flight Departing: ' + schedule.Name);
                email.setPlainTextBody(
                    'FLIGHT DEPARTURE ALERT\n\n' +
                    'Schedule: ' + schedule.Name + '\n' +
                    'Status: In Progress\n' +
                    'Departure Time: ' + schedule.Departure_Date_Time__c
                );
                emails.add(email);
            }
        }
    }
    
    if (!emails.isEmpty()) {
        Messaging.sendEmail(emails);
    }
}
```

---

## ✅ **TESTING THE AUTOMATION**

### Test Case 1: Create Schedule
```
1. Create new Flight Schedule
2. Expected: Email sent to admin
3. Verify: Check email inbox
```

### Test Case 2: Change Status to In Progress
```
1. Edit existing schedule
2. Change Status → In Progress
3. Expected: Departure email sent
4. Verify: Check email
```

### Test Case 3: Cancel Flight
```
1. Edit schedule
2. Change Status → Cancelled
3. Expected: Cancellation email sent to admin + pilots
4. Verify: All recipients received email
```

---

## 📝 **DOCUMENTATION FOR SUBMISSION**

Mention in your video/document:

**Automation Implemented:**
✅ Email notification on schedule creation
✅ Departure alerts when status changes to "In Progress"
✅ Cancellation alerts to admin and pilots
✅ Pilot assignment notifications with flight details

**Tools Used:**
- Record-Triggered Flows (OR)
- Apex Email Trigger (simpler alternative)
- Email Templates

---

## ⏰ **TIME ESTIMATE**

**Manual Flow Creation:** 30-45 minutes (all 4 flows)
**OR**
**Apex Trigger Method:** 10 minutes (deploy trigger)

**Recommend:** Use Apex Trigger for quick implementation!

---

**END OF FLOW IMPLEMENTATION GUIDE**
