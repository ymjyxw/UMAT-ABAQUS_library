find . -type f -path '*src/*' -name '*.for' -exec cat {} +> umat_an.for 
gfortran -Wextra  -pedantic -o an *.for *.f90
find . -type f -path '*src/*' -name '*.for' -not -name 'GETOUTDIR.for' -exec cat {} +> test_in_abaqus/umat_an.for 
