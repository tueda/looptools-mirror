# Check if quadruple precision arithmetic is available.
#
# Defines the following variables:
#
# * QUADRUPLE_PRECISION_Fortran_HAS_REAL16
#
# Requires the following module:
#
# * CheckFortranSourceRuns
#
include(CheckFortranSourceRuns)

function(check_quadruple_precision)
  set(_test_real16
      "
      program test
      real*16 a, b
      a = 2
      a = a ** (52/2+2)
      b = a + 1 / a
      if (a .eq. b) call exit(1)
      stop
      end program
  ")
  check_fortran_source_runs(${_test_real16}
                            QUADRUPLE_PRECISION_Fortran_HAS_REAL16)
endfunction()
