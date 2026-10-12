CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR Booking RESULT result.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
       keys FOR Booking~calculateTotalPrice.

ENDCLASS.

CLASS lhc_Booking IMPLEMENTATION.

  METHOD get_instance_features.
    ""Step 1: Read the data using EML
    READ ENTITIES OF zr_gs_m_travel in local mode
        entity booking
            fields ( bookingid CarrierId )
            with corRESPONDING #(   keys )
            result data(lt_bookings)
            failed failed.

    result = VALUE #(
      FOR ls_booking IN lt_bookings
        ( %tky = ls_booking-%tky
          %features-%field-ConnectionId =
            COND #(
              WHEN ls_booking-CarrierId ne 'AA'
              THEN if_abap_behv=>fc-f-read_only
              ELSE if_abap_behv=>fc-f-unrestricted
            )
        )
    ).
  ENDMETHOD.

  METHOD calculateTotalPrice.
        modify entities of zr_gs_m_travel in LOCAL MODE
        entity travel
            execute calcTotalPrice
                from corresponding #( keys ).
  ENDMETHOD.

ENDCLASS.
