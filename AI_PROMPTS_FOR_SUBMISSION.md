# AI Prompts for Airlines Management System Project
## Complete Prompts for Document & Video Generation

**Date:** October 21, 2026  
**Project:** Airlines Management System - Salesforce Capstone

---

## 📄 SECTION 1: DOCUMENT GENERATION PROMPTS

### Prompt 1: Project Overview Document

```
Create a comprehensive Salesforce project documentation for "Airlines Management System" with the following details:

PROJECT DETAILS:
- Student project for LNCT Group of Colleges
- Salesforce COE Skilling Program (Wipro partnership)
- Org: chandanpathak2005.fae1d6e8e465@agentforce.com
- 4 custom objects: Flight__c, Flight_Schedule__c, Pilot__c, Pilot_Schedule__c

INCLUDE:
1. Executive Summary
2. Custom Objects with all fields and data types
3. Relationships (Master-Detail and Lookup)
4. Formula Fields:
   - Duration calculation (Flight Schedule)
   - Age calculation (Pilot)
   - Level calculation (Pilot)
5. Validation Rules:
   - Departure before arrival
   - Different cities
   - Distinct pilots
   - Minimum age 18
   - Different first/last names
6. Apex Trigger Handler (FlightScheduleTriggerHandler)
7. SOQL Queries (parent-to-child and child-to-parent)
8. Testing scenarios
9. Technical architecture diagram description

FORMAT: Professional PDF-ready markdown with tables, code blocks, and clear sections.
TONE: Formal, technical, suitable for academic evaluation.
LENGTH: 15-20 pages
```

---

### Prompt 2: Video Script Generation

```
Create a detailed 8-10 minute video demonstration script for Airlines Management System Salesforce project.

STRUCTURE:
1. Introduction (1 min)
   - Student introduction
   - Project overview
   - LNCT/Wipro program mention

2. Application Tour (1 min)
   - Show App Launcher
   - Navigate through tabs
   - Overview of functionality

3. Data Model (2 min)
   - Schema Builder walkthrough
   - Explain 4 objects
   - Show relationships

4. Flight & Flight Schedule Demo (2 min)
   - Show Flight records
   - Create Flight Schedule
   - Demonstrate Duration formula field

5. Pilot Management (1.5 min)
   - Show Pilot records
   - Demonstrate Age and Level formulas
   - Explain validation rules

6. Apex Code Walkthrough (1.5 min)
   - Show FlightScheduleTriggerHandler
   - Explain duplicate prevention logic
   - Show AirlinesSOQLService

7. SOQL Query Demo (1 min)
   - Execute parent-to-child query
   - Show results in Developer Console

8. Conclusion (30 sec)
   - Summary of features
   - Thank you message

FORMAT: Include exact dialogue, screen navigation instructions, and timing for each section.
INCLUDE: What to show on screen, what to say, and transitions between sections.
```

---

### Prompt 3: Technical Specification Document

```
Generate technical specification document for Airlines Management System covering:

APEX CODE SPECIFICATIONS:
1. FlightScheduleTriggerHandler Class
   - Methods and their purposes
   - Duplicate prevention algorithm
   - Status update logic
   - Error handling

2. AirlinesSOQLService Class
   - All SOQL query methods
   - Parent-to-child queries with syntax
   - Child-to-parent queries with syntax
   - Filter methods (by status, city, date range)

FORMULA SPECIFICATIONS:
1. Duration Formula
   - Complete formula code
   - Calculation logic explanation
   - Output format

2. Age Formula
   - Complete formula code
   - Calculation method

3. Level Formula
   - Complete formula code
   - Conditional logic

VALIDATION RULES:
- Each rule with error condition formula
- Error messages
- Fields affected

FORMAT: Technical document with code snippets, formulas, and clear explanations.
```

---

### Prompt 4: Test Case Documentation

```
Create comprehensive test case documentation for Airlines Management System:

POSITIVE TEST CASES:
1. Valid Flight creation
2. Valid Flight Schedule with correct dates
3. Valid Pilot with age >= 18
4. Successful SOQL query execution

NEGATIVE TEST CASES:
1. Flight Schedule with departure after arrival (should fail)
2. Same source and destination city (should fail)
3. Pilot under 18 years (should fail)
4. Same pilot assigned twice (should fail)
5. Duplicate schedule attempt (should fail)

FOR EACH TEST CASE INCLUDE:
- Test Case ID
- Description
- Prerequisites
- Test Steps
- Input Data
- Expected Result
- Actual Result
- Status (Pass/Fail)

FORMAT: Table format with clear columns, suitable for evaluation.
```

---

## 🎥 SECTION 2: VIDEO CREATION PROMPTS

### Prompt 5: Video Script with Dialogue

```
Write a complete video narration script for Airlines Management System demo (8-10 minutes):

REQUIREMENTS:
- Natural, conversational tone
- Clear pronunciation guidance
- Exact words to speak at each screen
- Pauses and timing noted
- Screen navigation instructions
- What to click/show/highlight

STRUCTURE:
[SCREEN: Login]
NARRATOR: "Hello, my name is [Name]. Today I'm presenting..."
[PAUSE 2 seconds]
[CLICK: App Launcher]
NARRATOR: "Let me show you the Airlines Management System..."

Continue for all 8 sections with exact dialogue, screen actions, and timing.

INCLUDE:
- [SCREEN: xyz] tags for what's visible
- [CLICK: xyz] tags for actions
- [PAUSE: X seconds] for timing
- [POINT TO: xyz] for highlighting
- Complete sentences to speak
```

---

### Prompt 6: Video Storyboard

```
Create a detailed video storyboard for Airlines Management System demonstration:

FORMAT: 
Shot # | Time | Screen | Action | Narration | Notes
-------|------|--------|--------|-----------|------

INCLUDE 30-40 SHOTS covering:
1. Intro shots (login, app launcher)
2. Object list views
3. Record detail pages
4. Schema Builder views
5. Code views (Apex classes)
6. Developer Console
7. Formula field demonstrations
8. Closing shots

For each shot specify:
- Duration (in seconds)
- What's on screen
- What action to take
- What to say
- Any special notes (zoom, highlight, etc.)
```

---

### Prompt 7: Video Editing Instructions

```
Provide video editing instructions for Airlines Management System demo video:

RAW VIDEO: 10-15 minutes of screen recording following the script

EDITING TASKS:
1. Trim intro/outro
2. Remove long pauses (>3 seconds)
3. Add text overlays:
   - Student name at start
   - Project title
   - Key features list
   - Contact info at end
4. Add transitions between major sections (simple fade)
5. Highlight important elements:
   - Formula fields when shown
   - Code sections when explained
   - Validation error messages
6. Background music: soft, professional (optional, low volume)
7. Final export: 1080p MP4, 8-10 minutes

TOOLS TO USE:
- DaVinci Resolve (Free)
- Shotcut (Free)
- Windows Video Editor (Built-in)
- Kapwing (Online)

STEP-BY-STEP EDITING PROCESS with timestamps and specific cuts to make.
```

---

## 📸 SECTION 3: SCREENSHOT PROMPTS

### Prompt 8: Screenshot Checklist

```
Create a comprehensive screenshot capture checklist for Airlines Management System:

REQUIRED SCREENSHOTS (20 total):

DATA MODEL:
1. Schema Builder - all 4 objects visible
2. Flight object - fields list in Setup
3. Flight Schedule object - fields list
4. Pilot object - fields list
5. Object relationships diagram

RECORDS & DATA:
6. Flight list view (showing 2 records)
7. Flight detail page with related schedules
8. Flight Schedule list view
9. Flight Schedule detail showing Duration formula
10. Pilot list view
11. Pilot detail showing Age and Level formulas

CONFIGURATION:
12. Validation Rules list in Setup
13. Formula field definition - Duration
14. Formula field definition - Age
15. Formula field definition - Level

CODE:
16. FlightScheduleTriggerHandler - full class
17. AirlinesSOQLService - full class
18. Developer Console - SOQL query execution
19. Developer Console - Query results

APP:
20. App Launcher showing Airlines Management System

FOR EACH SCREENSHOT:
- Exact navigation path
- What to show on screen
- Resolution: 1920x1080
- File naming convention
- Any zoom/highlight needed
```

---

## 🎬 SECTION 4: PRESENTATION PROMPTS

### Prompt 9: PowerPoint Presentation

```
Create a PowerPoint presentation outline for Airlines Management System:

SLIDES (15-20):

1. Title Slide
   - Project name
   - Student name
   - LNCT / Wipro logos
   - Date

2. Agenda
   - What will be covered

3. Project Overview
   - Business objective
   - Key features

4-7. Data Model (4 slides)
   - One slide per object
   - Fields table
   - Relationships

8. Formula Fields
   - All 3 formulas with explanations

9. Validation Rules
   - List with descriptions

10-11. Apex Development (2 slides)
   - Trigger Handler
   - SOQL Service

12. Testing Results
   - Test cases summary table

13. Demo Screenshots
   - 4-6 key screenshots

14. Technical Architecture
   - Diagram/flow

15. Conclusion
   - Summary of achievements
   - Future enhancements

DESIGN:
- Professional Salesforce blue theme
- Minimal text per slide
- Code in monospace font
- Tables for data presentation
- Icons where appropriate
```

---

### Prompt 10: Verbal Presentation Script

```
Write a 5-minute verbal presentation script for Airlines Management System (without screen):

SCENARIO: Presenting to evaluators without computer/screen

STRUCTURE:
1. Introduction (30 sec)
   - Greeting
   - Project name
   - Program details

2. Problem Statement (30 sec)
   - What business problem it solves
   - Why Salesforce is suitable

3. Solution Overview (1 min)
   - 4 custom objects brief
   - Key relationships
   - Main functionality

4. Technical Highlights (2 min)
   - Formula fields and their logic
   - Validation rules importance
   - Apex trigger purpose
   - SOQL queries capability

5. Implementation Approach (1 min)
   - Development methodology
   - Testing strategy
   - Challenges faced and solved

6. Conclusion (30 sec)
   - Summary
   - Learning outcomes
   - Thank you

TONE: Confident, professional, suitable for academic evaluation
Include natural transitions between topics.
```

---

## 🤖 SECTION 5: AI-ASSISTED PROMPTS

### Prompt 11: ChatGPT for Documentation

```
I need help documenting my Salesforce Airlines Management System project. 

PROJECT DETAILS:
- 4 custom objects: Flight, Flight Schedule, Pilot, Pilot Schedule
- Formula fields: Duration, Age, Level
- Validation rules for data integrity
- Apex trigger handler for duplicate prevention
- SOQL queries for relationship navigation

TASK:
Create a professional project documentation including:
1. Executive summary
2. Object model with ER diagram description
3. Field-by-field documentation
4. Business rules and validations
5. Apex code explanation
6. Test scenarios

CONTEXT: This is for academic evaluation, needs to be formal and comprehensive.

OUTPUT FORMAT: Markdown with tables, suitable for PDF conversion.
```

---

### Prompt 12: Claude for Technical Writing

```
Help me write technical documentation for Airlines Management System Salesforce project.

COMPONENTS TO DOCUMENT:
1. FlightScheduleTriggerHandler class
   - Purpose: Prevent duplicate schedules, auto-update status
   - Methods: validateAndUpdate(), setStatusIfAvailable()
   - Logic: Checks Flight + Source + Destination + DateTime combination

2. AirlinesSOQLService class
   - 6 methods for querying data
   - Parent-to-child queries
   - Child-to-parent queries

3. Formula Fields:
   - Duration: Calculate hours and minutes from DateTime difference
   - Age: Calculate years from Date of Birth
   - Level: Assign Junior/Senior/Super Senior based on experience

AUDIENCE: Technical evaluators familiar with Salesforce
STYLE: Clear, concise, with code examples
INCLUDE: When to use each component, sample inputs/outputs
```

---

### Prompt 13: Loom AI for Video Script

```
Create a video recording script for my Salesforce project demo:

PROJECT: Airlines Management System
DURATION: 8-10 minutes
PURPOSE: Academic evaluation submission

SECTIONS TO COVER:
1. App overview and navigation
2. Data model explanation
3. Record creation demo
4. Formula fields demonstration
5. Apex code walkthrough
6. SOQL query execution

REQUIREMENTS:
- Natural, conversational language
- Clear instructions on what to click/show
- Proper pacing (not too fast)
- Professional tone suitable for evaluation

OUTPUT: Detailed script with screen actions and exact dialogue
```

---

## 📊 SECTION 6: DIAGRAM PROMPTS

### Prompt 14: Entity Relationship Diagram

```
Describe the Entity Relationship Diagram for Airlines Management System:

ENTITIES:
1. Flight (Master)
2. Flight Schedule (Detail of Flight)
3. Pilot (Independent)
4. Pilot Schedule (Junction)

RELATIONSHIPS:
- Flight 1:N Flight Schedule (Master-Detail)
- Flight Schedule N:1 Pilot (First Pilot - Lookup)
- Flight Schedule N:1 Pilot (Second Pilot - Lookup)
- Pilot Schedule N:1 Flight Schedule (Master-Detail)
- Pilot Schedule N:1 Pilot (Pilot 1 - Lookup)
- Pilot Schedule N:1 Pilot (Pilot 2 - Lookup)

OUTPUT: 
1. Text description of ER diagram
2. Instructions to create it in draw.io or Lucidchart
3. Box layout positions
4. Relationship lines and cardinality
5. Key fields to show in each entity box
```

---

### Prompt 15: Architecture Diagram

```
Create technical architecture diagram description for Airlines Management System:

LAYERS:
1. Presentation Layer
   - Lightning App: Airlines Management System
   - Standard UI components
   - Custom tabs

2. Business Logic Layer
   - FlightScheduleTriggerHandler (Apex)
   - AirlinesSOQLService (Apex)
   - Validation Rules
   - Formula Fields

3. Data Layer
   - Custom Objects (4)
   - Standard Salesforce database
   - Relationships

4. Integration Layer (Future)
   - Email notifications (Flows)
   - External systems

OUTPUT: 
- Textual description suitable for creating visual diagram
- Component interactions
- Data flow explanation
```

---

## 💾 SECTION 7: BACKUP & SUBMISSION PROMPTS

### Prompt 16: Submission Package Checklist

```
Create a comprehensive submission package checklist for Airlines Management System:

REQUIRED FILES:
□ PROJECT_SUBMISSION_DOCUMENT.pdf (main)
□ PROJECT_IMPLEMENTATION_REPORT.pdf (technical)
□ Video_Demo.mp4 (8-10 minutes)
□ Screenshots/ folder (20 images)
□ Source_Code/ folder (optional)
□ README.txt (submission notes)

FILE NAMING CONVENTION:
- StudentName_AirlinesManagement_Submission.pdf
- StudentName_AirlinesManagement_Video.mp4
- StudentName_AirlinesManagement_Screenshots.zip

VERIFICATION CHECKLIST:
□ All PDFs are readable
□ Video plays correctly
□ Audio is clear in video
□ Screenshots are high resolution
□ All files under size limit
□ Proper folder structure
□ Contact information included

SUBMISSION METHODS:
- Email to: [instructor email]
- Upload to: [LMS portal]
- Submission deadline: [date]

Create a final pre-submission checklist with all items to verify.
```

---

## 🎯 SECTION 8: QUICK REFERENCE PROMPTS

### Prompt 17: One-Line Project Description

```
Generate 5 variations of one-line project descriptions for Airlines Management System:

REQUIREMENTS:
- 15-20 words each
- Mention Salesforce
- Highlight key feature
- Suitable for resume/LinkedIn

VARIATIONS FOR:
1. Academic submission
2. LinkedIn post
3. Resume bullet point
4. Portfolio website
5. Email signature

EXAMPLE: "Salesforce-based Airlines Management System with custom objects, Apex triggers, and automated workflow for flight and pilot scheduling."
```

---

### Prompt 18: Elevator Pitch

```
Write a 30-second elevator pitch for Airlines Management System:

SCENARIO: Explaining project to:
1. Technical evaluator (Salesforce expert)
2. Non-technical professor
3. Industry recruiter
4. Fellow student

FOR EACH AUDIENCE:
- Opening hook
- Core functionality
- Technical highlights (adjust complexity)
- Impact/benefit
- Closing statement

Keep each pitch exactly 30 seconds when spoken at normal pace.
```

---

## 📝 HOW TO USE THESE PROMPTS

### Method 1: Copy-Paste into AI Tools

1. **ChatGPT / Claude:**
   ```
   Copy "Prompt 1" → Paste into ChatGPT
   Review output → Ask for modifications
   Export as markdown/PDF
   ```

2. **Loom AI (for video):**
   ```
   Copy "Prompt 5" → Paste into Loom
   Review script → Record following script
   Edit video → Export
   ```

3. **Canva AI (for presentation):**
   ```
   Copy "Prompt 9" → Create slides
   Add screenshots → Design
   Export as PDF
   ```

### Method 2: Combine Prompts

```
Use multiple prompts together:
"Prompt 1" + "Prompt 3" = Complete technical document
"Prompt 5" + "Prompt 6" = Video production package
"Prompt 8" + "Prompt 14" = Visual documentation
```

### Method 3: Iterative Refinement

```
Step 1: Use base prompt
Step 2: Review output
Step 3: Add follow-up: "Make it more technical" or "Simplify for beginners"
Step 4: Regenerate specific sections
Step 5: Finalize
```

---

## ⚡ QUICK START GUIDE

### For Documents (Right Now):

1. **Copy Prompt 1** → Paste in ChatGPT/Claude
2. **Copy Prompt 2** → Get video script
3. **Copy Prompt 8** → Get screenshot list
4. **Review outputs** → Make any adjustments
5. **Export as PDF** → Ready for submission

### For Video (Next 2 hours):

1. **Use Prompt 5** output as your script
2. **Follow Prompt 8** to capture screenshots
3. **Record using Loom/OBS** following the script
4. **Basic edit** using Prompt 7 guidelines
5. **Export** as MP4

### For Submission (Before deadline):

1. **Use Prompt 16** as final checklist
2. **Verify** all files ready
3. **Zip** everything together
4. **Submit** per instructions

---

## 🚀 ADVANCED TIPS

### Customizing Prompts:

Replace placeholders:
- [Your Name] → Your actual name
- [Date] → Today's date
- [Instructor Email] → Actual email
- [Duration] → Your preferred length

### Combining with Your Data:

```
Take any prompt above + Add your specific data:
"Use Prompt 1 but include these specific features: [list your features]"
```

### Platform-Specific:

**For ChatGPT:**
- Add "Use tables and code blocks"
- Add "Keep it under 4000 words"

**For Claude:**
- Add "Be detailed and technical"
- Add "Include code examples"

**For Gemini:**
- Add "Create in markdown format"
- Add "Include diagrams descriptions"

---

## 📌 FINAL NOTES

**Priority Order:**
1. Prompt 1 (Main document) - Do FIRST
2. Prompt 5 (Video script) - Do SECOND
3. Prompt 8 (Screenshots) - Do THIRD
4. Prompt 16 (Submission checklist) - Do LAST

**Time Estimates:**
- Documents: 30 minutes (using prompts)
- Video: 2 hours (recording + editing)
- Screenshots: 30 minutes
- Final review: 30 minutes
**Total: ~4 hours**

---

**END OF PROMPTS DOCUMENT**

**File:** AI_PROMPTS_AIRLINES_MANAGEMENT.md  
**Version:** 1.0  
**Date:** October 21, 2026  
**Status:** Ready to Use

---

*Copy any prompt above, paste into your preferred AI tool (ChatGPT, Claude, Gemini), and get instant results!*
