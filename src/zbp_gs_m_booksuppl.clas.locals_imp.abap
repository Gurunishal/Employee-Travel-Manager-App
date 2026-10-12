CLASS lhc_BookSuppl DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
       keys FOR BookSuppl~calculateTotalPrice.

ENDCLASS.

CLASS lhc_BookSuppl IMPLEMENTATION.

  METHOD calculateTotalPrice.

        modify entities of zr_gs_m_travel in LOCAL MODE
        entity travel
            execute calcTotalPrice
                from corresponding #( keys ).
  ENDMETHOD.

ENDCLASS.
