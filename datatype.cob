       IDENTIFICATION DIVISION.
       PROGRAM-ID. datatyp.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01 ARG1 PIC X(24).
       01 ARG2 PIC X(24).
       01 Arg4 USAGE COMP-1.
       01 Arg5 USAGE COMP-2.
       01 Arg6 BINARY-SHORT SIGNED.
       PROCEDURE DIVISION USING ARG1 ARG2 Arg4 Arg5 Arg6.
       MOVE "Replaced in COBOL" TO ARG2

       add 100.0 to Arg4.
       subtract 100.0 from Arg5.
       add 100 to Arg6.

       EXIT PROGRAM.
