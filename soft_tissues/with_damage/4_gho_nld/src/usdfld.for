      SUBROUTINE USDFLD(FIELD,STATEV,PNEWDT,DIRECT,T,CELENT,
     1 TIME,DTIME,CMNAME,ORNAME,NFIELD,NSTATV,NOEL,NPT,LAYER,
     2 KSPT,KSTEP,KINC,NDI,NSHR,COORD,JMAC,JMATYP,MATLAYO,LACCFLA)
C
      INCLUDE 'ABA_PARAM.INC'
      INCLUDE 'PARAM_UMAT.INC'
      COMMON/KPASSAGE/CMNV
C
      CHARACTER*80 CMNAME,ORNAME
      CHARACTER*3  FLGRAY(15)
      DIMENSION FIELD(NFIELD),STATEV(NSTATV),DIRECT(3,3),
     1 T(3,3),TIME(2)
      DIMENSION ARRAY(15),JARRAY(15),JMAC(*),JMATYP(*),COORD(*)
C
      DOUBLE PRECISION CMNV(NUEL,NIPP,6)
C---------IP COORDINATES AND IP VOLUME
C
      CALL GETVRM('IVOL',ARRAY,JARRAY,FLGRAY,JRCD,JMAC,JMATYP,MATLAYO,LACCFLA)
      CMNV(NOEL,NPT,1)=COORD(1)
      CMNV(NOEL,NPT,2)=COORD(2)
      CMNV(NOEL,NPT,3)=COORD(3)
      CMNV(NOEL,NPT,4)=ARRAY(1)
C
      RETURN
      END
      