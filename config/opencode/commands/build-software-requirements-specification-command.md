---
description: Generate a comprehensive Software Requirements Specification (SRS) following ISO/IEC/IEEE 29148:2011 standards. Use ASCII art for all diagrams.
---

# Build Software Requirements Specification

Create a comprehensive Software Requirements Specification (SRS) document following ISO/IEC/IEEE 29148:2011 standards (superseding IEEE 830-1998). Use ASCII art for all diagrams.

The SRS should serve as a "black box" specification—describing external behavior without detailing internal implementation. It must specify what functions are performed on what data to produce what results at what location for whom.

## Structure

1. Introduction
   - Purpose: Scope of the SRS and intended audience
   - Scope: What the software will/won't do; benefits, objectives, goals
   - Definitions, Acronyms, and Abbreviations
   - References: Related documents, standards, regulations
   - Overview: Organization of remaining sections

2. Overall Description
   - Product Perspective: System context, interfaces
   - Product Functions: Major functions summary
   - User Classes and Characteristics: Technical expertise, experience levels
   - Operating Environment: Hardware platform, OS, software components
   - Design and Implementation Constraints: Standards, regulations, limitations
   - User Documentation: Manuals, help, tutorials
   - Assumptions and Dependencies

3. Specific Requirements (Functional)
   Organize by: mode of operation, user class, object class, feature, stimulus/response, or functional hierarchy
   For each requirement provide:
   - Unique identifier (e.g., FR-001)
   - Description
   - Priority (Critical/High/Medium/Low)
   - Acceptance criteria

4. External Interface Requirements
   - User Interfaces: Screen layouts, GUI standards, accessibility
   - Hardware Interfaces: Supported devices, protocols
   - Software Interfaces: Databases, OS, tools, libraries, APIs
   - Communications Interfaces: Network protocols, data formats, security

5. Non-Functional Requirements (System Qualities)
   - Performance: Response time, throughput, capacity
   - Safety: Hazard prevention, fail-safe behaviors
   - Security: Authentication, authorization, data integrity, privacy, audit trails
   - Software Quality Attributes: Availability, maintainability, portability, reliability, reusability, testability

6. Other Requirements
   - Database requirements
   - Internationalization/localization
   - Legal compliance (GDPR, HIPAA, etc.)
   - Installation requirements

7. Appendices (as needed)
   - Data dictionary
   - Traceability matrix
   - Analysis models (ASCII diagrams)
   - List of to-be-determined items

## Constraints
- Use ASCII art for all diagrams (context diagrams, use cases, data flow diagrams, entity-relationship diagrams, state diagrams)
- Use "shall" for mandatory requirements, "should" for desirable, "will" for facts
- Avoid: "etc.", "and/or", "may", ambiguous language
- Ensure requirements are: correct, unambiguous, complete, consistent, ranked, verifiable, modifiable, traceable
- Use precise, formal technical writing

## Output Format
Professional technical document with:
- Clear hierarchical headings
- Tables for structured data (requirements, priorities, traceability)
- Numbered requirements for traceability
- ASCII diagrams where visual representation aids understanding
