      SUBROUTINE DEFORMATION(F,C,B,NDI)
C>     RIGHT AND LEFT CAUCHY-GREEN DEFORMATION TENSORS
      IMPLICIT NONE
      INCLUDE 'PARAM_UMAT.INC'
C
      INTEGER NDI
      DOUBLE PRECISION F(NDI,NDI),C(NDI,NDI),B(NDI,NDI)
C     RIGHT CAUCHY-GREEN DEFORMATION TENSOR
      C=MATMUL(TRANSPOSE(F),F)
C     LEFT CAUCHY-GREEN DEFORMATION TENSOR
      B=MATMUL(F,TRANSPOSE(F))
      RETURN
      END SUBROUTINE DEFORMATION
