SUBROUTINE affactnetfic_discrete(sfic,cfic,f,filprops,affprops,  &
        ru0,dtime,frac,efi,noel,vara,dirmax,det,factor,ndi)

!>    AFFINE NETWORK: 'FICTICIOUS' CAUCHY STRESS AND ELASTICITY TENSOR
!> DISCRETE ANGULAR INTEGRATION SCHEME (icosahedron)
use global
IMPLICIT NONE

INTEGER, INTENT(IN)                      :: ndi
DOUBLE PRECISION, INTENT(OUT)            :: sfic(ndi,ndi)
DOUBLE PRECISION, INTENT(OUT)            :: cfic(ndi,ndi,ndi,ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: f(ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: filprops(8)
DOUBLE PRECISION, INTENT(IN)             :: affprops(4)
DOUBLE PRECISION, INTENT(IN OUT)         :: efi
INTEGER, INTENT(IN OUT)                  :: noel
DOUBLE PRECISION, INTENT(IN OUT)         :: det

INTEGER :: j1,k1,l1,m1,im1,i1
DOUBLE PRECISION :: sfilfic(ndi,ndi), cfilfic(ndi,ndi,ndi,ndi)
DOUBLE PRECISION :: mfi(ndi),mf0i(ndi)
DOUBLE PRECISION :: aux,lambdai,dwi,ddwi,lambdaic
DOUBLE PRECISION :: l,r0f,r0,mu0,b0,beta,lambda0,rho,m,fi,ffi,dtime
DOUBLE PRECISION :: r0c,etac,lambdaif
DOUBLE PRECISION :: bdisp,fric,ffmax,ang, frac(4),ru0(720),ru
DOUBLE PRECISION :: vara,avga,maxa,aux0,ffic,suma,rho0,dirmax(ndi)

! INTEGRATION SCHEME
  integer ( kind = 4 ) node_num
  integer ( kind = 4 ) a
  real ( kind = 8 ) a_xyz(3)
  real ( kind = 8 ) a2_xyz(3)
  real ( kind = 8 ) ai !area of triangle i
  real ( kind = 8 ) area_total
  integer ( kind = 4 ) b
  real ( kind = 8 ) b_xyz(3)
  real ( kind = 8 ) b2_xyz(3)
  integer ( kind = 4 ) c
  real ( kind = 8 ) c_xyz(3)
  real ( kind = 8 ) c2_xyz(3)
  integer ( kind = 4 ) edge_num
  integer ( kind = 4 ), allocatable, dimension ( :, : ) :: edge_point
  integer ( kind = 4 ) f1
  integer ( kind = 4 ) f2
  integer ( kind = 4 ) f3
  integer ( kind = 4 ) face
  integer ( kind = 4 ) face_num
  integer ( kind = 4 ), allocatable, dimension ( : ) :: face_order
  integer ( kind = 4 ), allocatable, dimension ( :, : ) :: face_point
  integer ( kind = 4 ) face_order_max
  integer ( kind = 4 ) factor
  !external             fun
  real ( kind = 8 ) node_xyz(3)
  real ( kind = 8 ), parameter :: pi = 3.141592653589793D+00
  real ( kind = 8 ), allocatable, dimension ( :, : ) :: point_coord
  integer ( kind = 4 ) point_num
  real ( kind = 8 ) rr, aa
  real ( kind = 8 ) v



!  Size the icosahedron.
!
  call icos_size ( point_num, edge_num, face_num, face_order_max )
!
!  Set the icosahedron.
!
  allocate ( point_coord(1:3,1:point_num) )
  allocate ( edge_point(1:2,1:edge_num) )
  allocate ( face_order(1:face_num) )
  allocate ( face_point(1:face_order_max,1:face_num) )

  call icos_shape ( point_num, edge_num, face_num, face_order_max, &
    point_coord, edge_point, face_order, face_point )
!
!  Initialize the integral data.
!
  rr = 0.0D+00
  area_total = 0.0D+00
  node_num = 0
  

!! initialize the model data
  !     FILAMENT
l       = filprops(1)
r0f     = filprops(2)
r0c     = filprops(3)
etac    = filprops(4)
mu0     = filprops(5)
beta    = filprops(6)
b0      = filprops(7)
lambda0 = filprops(8)
!     NETWORK
m       = affprops(1)
bdisp       = affprops(2)
fric    = affprops(3)
ffmax   = affprops(4)

  aux=m*(det**(-one))
  cfic=zero
  sfic=zero

  rho=one
  r0=r0f+r0c

  aa = zero
  avga=zero
  maxa=zero
  suma=zero
  dirmax=zero

!  Pick a face of the icosahedron, and identify its vertices as A, B, C.
!
  do face = 1, face_num
!
    a = face_point(1,face)
    b = face_point(2,face)
    c = face_point(3,face)
!
    a_xyz(1:3) = point_coord(1:3,a)
    b_xyz(1:3) = point_coord(1:3,b)
    c_xyz(1:3) = point_coord(1:3,c)
!
!  Some subtriangles will have the same direction as the face.
!  Generate each in turn, by determining the barycentric coordinates
!  of the centroid (F1,F2,F3), from which we can also work out the barycentric
!  coordinates of the vertices of the subtriangle.
!
    do f3 = 1, 3 * factor - 2, 3
      do f2 = 1, 3 * factor - f3 - 1, 3
        !update triangle centroid index
        node_num = node_num + 1 
        f1 = 3 * factor - f3 - f2
        call sphere01_triangle_project ( a_xyz, b_xyz, c_xyz, f1, f2, f3, &
          node_xyz )

        call sphere01_triangle_project ( &
          a_xyz, b_xyz, c_xyz, f1 + 2, f2 - 1, f3 - 1, a2_xyz )
        call sphere01_triangle_project ( &
          a_xyz, b_xyz, c_xyz, f1 - 1, f2 + 2, f3 - 1, b2_xyz )
        call sphere01_triangle_project ( &
          a_xyz, b_xyz, c_xyz, f1 - 1, f2 - 1, f3 + 2, c2_xyz )

        call sphere01_triangle_vertices_to_area ( a2_xyz, b2_xyz, c2_xyz, ai )

        !direction of the sphere triangle barycenter - direction i
        mf0i=node_xyz
        CALL deffil(lambdai,mfi,mf0i,f,ndi)

  
        IF((etac > zero).AND.(etac < one))THEN
            lambdaif=etac*(r0/r0f)*(lambdai-one)+one
            lambdaic=(lambdai*r0-lambdaif*r0f)/r0c
        ELSE
            lambdaif=lambdai
            lambdaic=zero
        END IF
          
        ru=ru0(node_num)
        CALL contractile(fi,ffi,dwi,ddwi,ffic,ru,ru,lambdaic,lambdaif,  &
            lambda0,l,r0,mu0,beta,b0,ffmax,fric,frac,dtime)
        ru0(node_num)=ru
      !       write(*,*) i1,     LAMBDAIF, ru
        
        CALL bangle(ang,f,mfi,noel,ndi)
        
        CALL density(rho,ang,bdisp,efi)
        
      !        AUX0=(FFIC/FFMAX)*(RHO)
        aux0=ru*rho
        
        IF (ru > zero) THEN
      !        AVERAGE CONTRACTION LEVEL
          avga=avga+aux0
          suma=suma+one
          IF (aux0 > maxa) THEN
      !        MAXIMUM CONTRACTION LEVEL
            maxa = aux0
            dirmax=mfi
            im1=i1
          END IF
        END IF
        
        CALL sigfilfic(sfilfic,rho,lambdaif,dwi,mfi,ai,ndi)
  
        CALL csfilfic(cfilfic,rho,lambdaif,dwi,ddwi,mfi,ai,ndi)
  
  
        IF(ru > zero)THEN
          
          DO j1=1,ndi
            DO k1=1,ndi
              sfic(j1,k1)=sfic(j1,k1)+aux*sfilfic(j1,k1)
              DO l1=1,ndi
                DO m1=1,ndi
                  cfic(j1,k1,l1,m1)=cfic(j1,k1,l1,m1)+aux*cfilfic(j1,k1,l1,m1)
                END DO
              END DO
            END DO
          END DO
          
        END IF
        
        !v=dwi
        !node_num = node_num + 1
        !rr = rr + ai * v
        !area_total = area_total + ai

      end do
    end do
!
!  The other subtriangles have the opposite direction from the face.
!  Generate each in turn, by determining the barycentric coordinates
!  of the centroid (F1,F2,F3), from which we can also work out the barycentric
!  coordinates of the vertices of the subtriangle.
!
    do f3 = 2, 3 * factor - 4, 3
      do f2 = 2, 3 * factor - f3 - 2, 3
        !update triangle centroid index
        node_num = node_num + 1 
        f1 = 3 * factor - f3 - f2

        call sphere01_triangle_project ( a_xyz, b_xyz, c_xyz, f1, f2, f3, &
          node_xyz )

        call sphere01_triangle_project ( &
          a_xyz, b_xyz, c_xyz, f1 - 2, f2 + 1, f3 + 1, a2_xyz )
        call sphere01_triangle_project ( &
          a_xyz, b_xyz, c_xyz, f1 + 1, f2 - 2, f3 + 1, b2_xyz )
        call sphere01_triangle_project ( &
          a_xyz, b_xyz, c_xyz, f1 + 1, f2 + 1, f3 - 2, c2_xyz )

        call sphere01_triangle_vertices_to_area ( a2_xyz, b2_xyz, c2_xyz, ai )

        !direction of the sphere triangle barycenter - direction i
        mf0i=node_xyz
         CALL deffil(lambdai,mfi,mf0i,f,ndi)

  
        IF((etac > zero).AND.(etac < one))THEN
            lambdaif=etac*(r0/r0f)*(lambdai-one)+one
            lambdaic=(lambdai*r0-lambdaif*r0f)/r0c
        ELSE
            lambdaif=lambdai
            lambdaic=zero
        END IF
          
        ru=ru0(node_num)
        CALL contractile(fi,ffi,dwi,ddwi,ffic,ru,ru,lambdaic,lambdaif,  &
            lambda0,l,r0,mu0,beta,b0,ffmax,fric,frac,dtime)
        ru0(node_num)=ru
      !       write(*,*) i1,     LAMBDAIF, ru
        
        CALL bangle(ang,f,mfi,noel,ndi)
        
        CALL density(rho,ang,bdisp,efi)
        
      !        AUX0=(FFIC/FFMAX)*(RHO)
        aux0=ru*rho
        
        IF (ru > zero) THEN
      !        AVERAGE CONTRACTION LEVEL
          avga=avga+aux0
          suma=suma+one
          IF (aux0 > maxa) THEN
      !        MAXIMUM CONTRACTION LEVEL
            maxa = aux0
            dirmax=mfi
            im1=i1
          END IF
        END IF
        
        CALL sigfilfic(sfilfic,rho,lambdaif,dwi,mfi,ai,ndi)
  
        CALL csfilfic(cfilfic,rho,lambdaif,dwi,ddwi,mfi,ai,ndi)
  
  
        IF(ru > zero)THEN
          
          DO j1=1,ndi
            DO k1=1,ndi
              sfic(j1,k1)=sfic(j1,k1)+aux*sfilfic(j1,k1)
              DO l1=1,ndi
                DO m1=1,ndi
                  cfic(j1,k1,l1,m1)=cfic(j1,k1,l1,m1)+aux*cfilfic(j1,k1,l1,m1)
                END DO
              END DO
            END DO
          END DO
          
        END IF
        
        
        !v=dwi
        !node_num = node_num + 1  
        !rr = rr + ai * v
        !area_total = area_total + ai

      end do
    end do


  IF (suma > zero) THEN
    avga=avga/node_num
  END IF
  vara=(maxa-avga)/maxa
  !        WRITE(*,*) VARA,MAXA,IM1,SUMA

  end do
!
!  Discard allocated memory.
!
  deallocate ( edge_point )
  deallocate ( face_order )
  deallocate ( face_point )
  deallocate ( point_coord )


RETURN
END SUBROUTINE affactnetfic_discrete
