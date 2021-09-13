       IDENTIFICATION DIVISION.
       PROGRAM-ID. datatype.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01 ARG1 PIC X(24).
       01 ARG2 PIC X(24).
       01 Arg3 USAGE COMP-1.
       01 Arg4 USAGE COMP-2.
       01 Arg5 BINARY-SHORT SIGNED.
       PROCEDURE DIVISION USING ARG1 ARG2 Arg3 Arg4 Arg5.
           MOVE z"Replaced in MFCOBOL" TO ARG2
    
           add 100.0 to Arg3.
           subtract 100.0 from Arg4.
           add 100 to Arg5.

       EXIT PROGRAM.
