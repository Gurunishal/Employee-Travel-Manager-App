# Employee-Travel-Manager-App
App to manage and approve Employee travel organized by the company

- We are working in an MNC who is willing to design a system for their employees to manage corporate travel. Two applications to be designed for different user persona (role-based):
    - Employees to manage travel request (**Processor App**) - App which allows the employee to create/update/delete travel request, bookings (1..*) and booking supplements (1..*)
    - Manager to approve or reject the travel request (**Approver App**) - App which allows the managers to approve/reject/change booking fee for the corresponding travel requests.
- BO Layer (Base Layer)
    - From structural POV, a BO in RAP is a composition tree which starts from Root node, each node represents a CDS Entity. The whole tree is the BO.
    - In our requirement, our BO include:
        - Travel (ROOT)
        - Bookings
        - Booking Supplement

Step by Step dev flow:

- Business Object:

<img width="557" height="242" alt="Screenshot 2026-09-16 at 2 33 21 PM" src="https://github.com/user-attachments/assets/ac5527ce-0280-482d-a7d7-c1ad6a2df730" />

- Processor Projection (Employee)
    - Definition of BO Projection Layer:
        - redirected to composition child/parent in Projection to form Business Object
    - Service definition for processor
    - Service binding for processor
