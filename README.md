# Employee Travel Manager

A SAP Fiori Elements application for browsing and managing travel requests, bookings, and booking supplements. The project is built with the ABAP RESTful Application Programming Model (RAP) and uses SAP's `/DMO` travel model and sample data.

> **Current scope:** The repository contains the travel processor experience and RAP business object. A separate manager approval experience (approve/reject actions and booking-fee changes) is not included in the current implementation.

## What it demonstrates

- A RAP composition tree with Travel as the root, Bookings as a child, and Booking Supplements as a grandchild.
- CDS interface entities and processor projection entities with redirected parent and child associations.
- Managed RAP behavior for create, update, and delete operations across the travel hierarchy.
- A service definition and service bindings for exposing the processor projection.
- A Fiori Elements list report and object page, including travel details and a bookings table.
- Value helps and descriptive text for related demo entities such as agencies, customers, carriers, connections, currencies, and statuses.

## Business scenario

The intended scenario is corporate travel management: employees maintain travel requests and their bookings, while managers review requests. The current code provides the processor-side data model and CRUD workflow. It uses `/DMO` sample travel data, whose entities represent demo travel customers, agencies, and bookings; it is not connected to an employee master or a corporate HR system.

## Data model

```text
ZR_GS_M_TRAVEL (root)
└── ZR_GS_M_BOOKING
    └── ZR_GS_M_BOOKSUPPPL
```

The entities select from these SAP demo tables:

| RAP entity | Persistence source | Role |
|---|---|---|
| `ZR_GS_M_TRAVEL` | `/DMO/TRAVEL_M` | Travel request root |
| `ZR_GS_M_BOOKING` | `/DMO/BOOKING_M` | Booking child |
| `ZR_GS_M_BOOKSUPPPL` | `/DMO/BOOKSUPPL_M` | Booking supplement grandchild |

Processor projection entities are `Z_GS_M_TRAVEL_PROCESSOR`, `Z_GS_M_BOOKING_PROCESSOR`, and `Z_GS_M_BOOKSUPPL_PROCESSOR`. Their associations redirect the composition tree for consumption by the processor service.

## Repository layout

```text
src/
  zr_gs_m_travel.*                 Travel root CDS entity and RAP behavior
  zr_gs_m_booking.*                Booking CDS entity
  zr_gs_m_booksupppl.*             Booking supplement CDS entity
  z_gs_m_*_processor.*             Processor projection entities and behavior
  z_gs_sd_m_travel.*               Service definition
  z_gs_m_travel_proc_v*.srvb.xml   Service binding metadata
  zbp_r_gs_m_travel.*              Behavior pool class
```

ADT/abapGit stores ABAP object source and related metadata in separate files. Files sharing an object name but carrying different extensions are usually parts of the same repository object; retain the companion files when importing or exporting the project.

## Prerequisites

- Access to an SAP ABAP system with RAP and Fiori Elements support.
- The `/DMO` travel demo objects and sample data available in that system.
- ABAP Development Tools (ADT) for Eclipse.
- A service binding supported by the target system and a Fiori Elements preview or launch environment.

The project is ABAP source and metadata; it is not a standalone web application that can be started with a local Node.js command.

## Import and run

1. In ADT, connect to the target ABAP system and use the abapGit integration or your system's supported source-import process to import the repository objects.
2. Activate the CDS entities, behavior definitions, behavior pool, projection entities, service definition, and metadata extensions in dependency order. Resolve any package or namespace differences required by the system.
3. Activate the desired service binding. The repository contains versioned binding artifacts; use the binding that is active and compatible with your system.
4. Publish the binding and open its Fiori Elements preview, or configure a launchpad target according to the system's setup.
5. Use the list report to browse travel records and open a travel to inspect its general information and bookings.

Exact import and publication steps can vary by SAP training-system configuration and user authorization.

## Current limitations and next steps

- The business object uses `/DMO` demo persistence and sample entities, not employee or HR master data.
- The repository describes a processor service; a role-separated manager app and approval actions are not present in the current behavior definition.
- The behavior pool currently has no custom implementation logic. The managed behavior supplies the configured persistence operations.
- The CDS entities declare `@AccessControl.authorizationCheck: #NOT_REQUIRED`; production-ready employee/manager authorization is not demonstrated here.
- The current model's cardinalities and create capabilities should be reviewed against the target use case before treating it as a production corporate travel design.

Potential extensions include a manager projection and service, submit/approve/reject actions with status validations, instance authorization, and integration with released employee and organizational data sources.

## Author

Gurunishal Saravanan
