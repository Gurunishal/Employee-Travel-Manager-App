CLASS lhc_booking DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR Booking RESULT result.

ENDCLASS.

CLASS lhc_booking IMPLEMENTATION.

  METHOD get_instance_features.

    "Step 1: Read data using EML
    READ ENTITIES OF zr_gs_m_travel in LOCAL MODE
        entity Booking
            fields ( CarrierId )
            with CORRESPONDING #( keys )
            result data(lt_bookings)
            failed failed.
    "Step 2: Return the result to check whether the Carrier ID is AA
    READ TABLE lt_bookings into data(ls_bookings) index 1.

    "Step 3: Determine if the Carrier ID is AA
    result = VALUE #(
        FOR booking IN lt_bookings
            ( %tky = booking-%tky
            %field-ConnectionId = COND #(
                WHEN booking-CarrierId = 'AA'
                THEN if_abap_behv=>fc-f-unrestricted
                ELSE if_abap_behv=>fc-f-read_only ) ) ).

  ENDMETHOD.

ENDCLASS.

CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR Travel RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR Travel RESULT result.
    METHODS copytravel FOR MODIFY
      keys FOR ACTION travel~copytravel.
    METHODS earlynumbering_cba_Booking FOR NUMBERING
      entities FOR CREATE Travel\_Booking.
    METHODS earlynumbering_create FOR NUMBERING
      entities FOR CREATE Travel.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.

  ENDMETHOD.

  METHOD get_global_authorizations.

  ENDMETHOD.

  METHOD earlynumbering_create.


    "Step 1: Data type declaration
    DATA: entity type structure for create zr_gs_m_travel\\travel,
          travel_id_max TYPE /dmo/travel_id.

    "Step 2: Ensure that the travel id is not set for any of the record.
    LOOP AT entities into entity where travelid is not initial.
        APPEND CORRESPONDING #( entity ) to mapped-travel.
    endloop.

    "Step 3: Keep the records where travel id is blank - developer takes control to generate id
    DATA(entities_without_travelid) = entities.
    delete entities_without_travelid where travelid is NOT initial.

    "Step 4: Get the sequence number from snro --> starting sequence number, how many numbers
    try.

      cl_numberrange_runtime=>number_get(
        Exporting
            nr_range_nr = '01'
            object = conv #( '/DMO/TRAVL' )
            quantity = conv #( LINES( entities_without_travelid ) )
        IMPORTING
            number = data(number_range_key)
            returncode = data(number_range_key_code)
            returned_quantity = data(number_range_return_quantity)
       ).

       CATCH cx_nr_object_not_found into data(lx_not_found).
        loop at entities_without_travelid into entity.
            append value #( %cid = entity-%cid %key = entity-%key %msg = lx_not_found ) to reported-travel.
            append value #( %cid = entity-%cid %key = entity-%key ) to failed-travel.
        endloop.

        CATCH cx_number_ranges into data(lx_number_range).
            append value #( %cid = entity-%cid %key = entity-%key %msg = lx_number_range ) to reported-travel.
            append value #( %cid = entity-%cid %key = entity-%key ) to failed-travel.

    endtry.

    "Step 5: count the records, loop the data and assign number range by incrementing one everytime
    assert number_range_return_quantity = lines( entities_without_travelid ).

    travel_id_max = number_range_key - number_range_return_quantity.

    LOOP AT entities_without_travelid into entity.
        travel_id_max += 1.
        entity-TravelId = travel_id_max.

        append value #( %cid = entity-%cid %key = entity-%key ) to mapped-travel.
    ENDLOOP.



  ENDMETHOD.

  METHOD earlynumbering_cba_Booking.

    "Step 1: Define variable to get max booking id for given travel
    DATA: max_booking_id TYPE /dmo/booking_id.

    "Step 2: Use select query to get the bookings which are already added to travel
    READ ENTITIES OF ZR_GS_M_TRAVEL IN LOCAL MODE
        entity travel by \_Booking
        FROM CORRESPONDING #( entities )
        link data(lt_bookings).

    "Step 3: Loop at Travel records and assign booking id inside each travel record
    loop AT entities assigning FIELD-SYMBOL(<travel_group>) GROUP BY <travel_group>-TravelId.

        "Step 4: Get the highest booking number for the corresponding travel request
        LOOP AT lt_bookings into data(ls_booking) using key entity
                                                  WHERE source-TravelId = <travel_group>-TravelId.
            if max_booking_id < ls_booking-target-BookingId.
                max_booking_id = ls_booking-target-BookingId.
            ENDIF.
        endloop.

        "Step 5: Get the assigned booking number from incoming request
        LOOP AT entities into data(ls_entity) using KEY entity
                                              WHERE travelid = <travel_group>-TravelId.
            LOOP AT ls_entity-%target into data(ls_target).
                if max_booking_id < ls_target-BookingId.
                    max_booking_id = ls_target-BookingId.
            ENDIF.
            ENDLOOP.
        ENDLOOP.

        "Step 6: Loop at entities over all entries and assign an incremented booking id by 10
        LOOP AT entities assigning FIELD-SYMBOL(<travel>) using KEY entity
                                              WHERE travelid = <travel_group>-TravelId.
            LOOP AT <travel>-%target assigning FIELD-SYMBOL(<booking_wo_numbers>).
                append CORRESPONDING #( <booking_wo_numbers> ) to mapped-booking
                                                  assigning field-SYMBOL(<mapped_booking>).
                if <mapped_booking>-BookingId is initial.
                    max_booking_id += 10.
                    <mapped_booking>-BookingId = max_booking_id.
            ENDIF.
            ENDLOOP.
        ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_instance_features.

    "Step 1: Read data using EML
    READ ENTITIES OF ZR_GS_M_TRAVEL in LOCAL MODE
        entity Travel
            fields ( TravelId OverallStatus )
            with CORRESPONDING #( keys )
            result data(lt_travels)
            failed failed.

    "Step 2: Return the result with whether the booking creation is possible or not
    READ TABLE lt_travels into data(ls_travel) index 1.

    "Step 3: Determine if the status is rejected
    IF ( ls_travel-OverallStatus = 'X' ).
        data(lv_allow) = if_abap_behv=>fc-o-disabled.

    ELSE.
        lv_allow = if_abap_behv=>fc-o-enabled.

    ENDIF.

    RESULT = value #( for travel in lt_travels (
                          %tky = travel-%tky
                          %assoc-_Booking = lv_allow
                           ) ).

  ENDMETHOD.

  METHOD copyTravel.

    "Step 1: Declare new Internal table to store data to be created
    Data: travels type table for create zr_gs_m_travel\\Travel,
          bookings_cba type table for create zr_gs_m_travel\\Travel\_Booking.

    "Step 2: Remove the travel instances with initial %cid
    read table keys WITH key %cid = '' into data(key_with_initial_cid).
    assert key_with_initial_cid is INITIAL.

    "Step 3: Read all the travel data for incoming travel id
    READ entities of zr_gs_m_travel in LOCAL mode
        entity travel
            all fields with corresponding  #( keys )
            result data(lt_travel)
            failed failed.

    READ entities of zr_gs_m_travel in LOCAL mode
        entity travel by \_Booking
            all fields with corresponding  #( keys )
            result data(lt_booking)
            failed failed.

    "Step 4: Loop at actual data and prepare our table to create new travel req
    loop AT lt_travel ASSIGNING FIELD-SYMBOL(<travel>).
        APPEND value #( %cid = keys[ %tky = <travel>-%tky ]-%cid
                        %data = corresponding #( <travel> except travelid )
            ) to travels assigning FIELD-SYMBOL(<new_travel>).

            <new_travel>-BeginDate = cl_abap_context_info=>get_system_date( ).
            <new_travel>-EndDate = cl_abap_context_info=>get_system_date( ) + 5.
            <new_travel>-OverallStatus = 'O'.
    ENDLOOP.

    "Step 4.1: Fill the booking internal table for data creation - deep copy
    append value #( %cid_ref = keys[ %tky = <travel>-%tky ]-%cid
                    ) to bookings_cba assigning field-symbol(<bookings_cba>).

    LOOP AT lt_booking assigning FIELD-SYMBOL(<booking>) where travelid = <travel>-TravelId.

        APPEND value #( %cid = keys[ %tky = <travel>-%tky ]-%cid && <booking>-BookingId
                        %data = CORRESPONDING #( lt_booking[ key entity %tky = <booking>-%tky ] except travelid )
                        ) to <bookings_cba>-%target assigning FIELD-SYMBOL(<new_booking>).

        <new_booking>-BookingStatus = 'N'.


    ENDLOOP.

    "Step 5: Fire EML to create new data in db
    MODIFY ENTITIES of zr_gs_m_travel in LOCAL MODE
        ENTITY TRAVEL
            CREATE FIELDS ( agencyid customerid BeginDate EndDate BookingFee TotalPrice CurrencyCode OverallStatus )
                WITH travels
            CREATE BY \_Booking fields ( BookingId BookingDate CustomerId CarrierId ConnectionId FlightDate FlightPrice CurrencyCode BookingStatus )
                with bookings_cba

            mapped data(mapped_create).


    mapped-travel = mapped_create-travel.

  ENDMETHOD.

ENDCLASS.
