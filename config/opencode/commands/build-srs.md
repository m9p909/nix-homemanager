---
description: Generate a comprehensive Software Requirements Specification (SRS) following ISO/IEC/IEEE 29148:2018 standards
---

# Build Software Requirements Specification

You are creating a comprehensive Software Requirements Specification (SRS) document following ISO/IEC/IEEE 29148:2018 standards.

## Core Principles
- **Black box specification**: Describe external behavior, not internal implementation
- **Precise language**: Use "shall" (mandatory), "should" (desirable), "will" (facts)
- **ASCII diagrams only**: No external image formats
- **Traceability**: Every requirement has unique identifier (e.g., FR-001, NFR-005)

## Document Structure

### 1. Introduction
- **Purpose**: Scope and intended audience
- **Scope**: What will/won't be done; benefits, objectives, goals
- **Definitions, Acronyms, Abbreviations**: All technical terms defined
- **References**: Related documents, standards, regulations
- **Overview**: Organization of document sections

### 2. Overall Description
- **Product Perspective**: System context with ASCII context diagram
- **Product Functions**: Summary of major functions
- **User Classes & Characteristics**: Technical levels, experience, expertise
- **Operating Environment**: Hardware platform, OS, software components
- **Design Constraints**: Standards, regulations, limitations
- **Assumptions & Dependencies**: What must be true for system to work

### 3. Specific Requirements (Functional)
For each requirement provide:
```
FR-XXX: [Requirement Title]
Description: [What the system shall do]
Priority: [Critical/High/Medium/Low]
Acceptance Criteria: [How to verify it works]
```

Organize by: user class, feature, functional hierarchy, or stimulus/response

### 4. External Interface Requirements
- **User Interfaces**: Screen layouts, accessibility standards (WCAG)
- **Hardware Interfaces**: Supported devices, protocols, port specifications
- **Software Interfaces**: Databases, APIs, libraries, OS requirements
- **Communication Interfaces**: Network protocols, data formats, security

### 5. Non-Functional Requirements
- **Performance**: Response times, throughput, capacity, latency
- **Safety**: Hazard prevention, fail-safe behaviors
- **Security**: Authentication, authorization, encryption, audit trails, privacy (GDPR, HIPAA compliance)
- **Quality Attributes**: Availability, maintainability, portability, reliability, testability

### 6. Other Requirements
- Database schema requirements
- Internationalization/localization needs
- Legal/regulatory compliance
- Installation and deployment requirements

### 7. Appendices
- Data dictionary (all data entities)
- Traceability matrix (requirements → design → test)
- ASCII diagrams (context, data flow, state, entity-relationship)
- TBD items (to-be-determined)

## Quality Checklist
- [ ] Each requirement is necessary, unambiguous, complete
- [ ] No vague language ("etc.", "and/or", "may", "user-friendly")
- [ ] All requirements ranked by priority
- [ ] All requirements are verifiable/testable
- [ ] Cross-references and traceability established
- [ ] Consistent technical terminology throughout
- [ ] ASCII diagrams used for visual concepts

## Task

Create an SRS for: $ARGUMENTS

Ask me for the project details if not provided, then systematically work through each section building a comprehensive, professional SRS document.
