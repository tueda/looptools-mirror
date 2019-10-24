include(CheckFortranCompilerFlag)
include(CheckQuadruplePrecision)
include(TestBigEndian)

check_quadruple_precision()

set(looptools_build_double TRUE)
set(looptools_build_quad ${QUADRUPLE_PRECISION_Fortran_HAS_REAL16})

function(complexize)
  foreach(filename_body IN LISTS ARGN)
    configure_file("${CMAKE_CURRENT_SOURCE_DIR}/${filename_body}.F"
                   "${CMAKE_CURRENT_BINARY_DIR}/${filename_body}C.F" COPYONLY)
    set_source_files_properties(${filename_body}C.F PROPERTIES
                                COMPILE_DEFINITIONS "COMPLEXPARA")
  endforeach()
endfunction()

complexize(
  A/Aget
  B/BcoeffFF
  B/Bget
  C/Cget
  D/Dget
  E/E0func
  E/Ecoeffa
  E/Ecoeffb
  E/Eget
  util/Dump
  util/Li2
  util/Li2omx
  util/solve)

set(looptools_source
    A/Aget.F
    A/AgetC.F
    A/ffca0.F
    A/ffxa0.F
    B/Bcoeff.F
    B/BcoeffAD.F
    B/BcoeffC.F
    B/BcoeffFF.F
    B/BcoeffFFC.F
    B/Bget.F
    B/BgetC.F
    B/ffcb0.F
    B/ffcb1.F
    B/ffcb2p.F
    B/ffcdb0.F
    B/ffcel2.F
    B/ffdel2.F
    B/ffxb0.F
    B/ffxb1.F
    B/ffxb2p.F
    B/ffxdb0.F
    B/ffxdb1.F
    C/C0func.F
    C/C0funcC.F
    C/Cget.F
    C/CgetC.F
    C/ffcc0.F
    C/ffcc0p.F
    C/ffcel3.F
    C/ffdel3.F
    C/ffdxc0.F
    C/ffxc0.F
    C/ffxc0i.F
    C/ffxc0p.F
    C/ffxc0p0.F
    D/D0func.F
    D/D0funcC.F
    D/D0z.F
    D/Dget.F
    D/DgetC.F
    D/ffRn.F
    D/ffS2.F
    D/ffS3n.F
    D/ffT13.F
    D/ffTn.F
    D/ffd0c.F
    D/ffdcc0.F
    D/ffdel4.F
    D/ffxd0.F
    D/ffxd0h.F
    D/ffxd0i.F
    D/ffxd0m0.F
    D/ffxd0p.F
    D/ffxd0tra.F
    D/ffxdbd.F
    E/E0func.F
    E/E0funcC.F
    E/Ecoeffa.F
    E/EcoeffaC.F
    E/Ecoeffb.F
    E/EcoeffbC.F
    E/Eget.F
    E/EgetC.F
    E/ffdel5.F
    E/ffxe0.F
    util/Dump.F
    util/DumpC.F
    util/Li2.F
    util/Li2C.F
    util/Li2omx.F
    util/Li2omxC.F
    util/auxCD.F
    util/cache.c
    util/ff2dl2.F
    util/ffabcd.F
    util/ffbndc.F
    util/ffcli2.F
    util/ffcrr.F
    util/ffcxr.F
    util/ffcxs3.F
    util/ffcxs4.F
    util/ffcxyz.F
    util/ffdcxs.F
    util/ffinit.F
    util/fftran.F
    util/ffxli2.F
    util/ffxxyz.F
    util/ini.F
    util/solve.F
    util/solveC.F)

function(target_common_options target quad)
  target_include_directories(${target} PRIVATE include)

  # NOTE: it is difficult to apply target_compile_options only to Fortran source
  # files in a cross-platform way. So C compilers may warn invalid options.

  # We need to relax the limitation of 72 characters in FORTRAN 77.
  if(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
    target_compile_options(${target} PRIVATE -ffixed-line-length-none
                                             -fno-range-check)
  elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "Intel")
    target_compile_options(
      ${target}
      PRIVATE -extend_source
              -warn
              truncated_source
              -warn
              nouncalled
              -assume
              bscc)
  endif()

  # Double/quadruple precision.
  if(quad STREQUAL "0")
    target_compile_definitions(${target} PRIVATE QUAD=0)
    target_compile_definitions(${target} PRIVATE QUADSIZE=0)
  elseif(quad STREQUAL "16")
    target_compile_definitions(${target} PRIVATE QUAD=1)
    target_compile_definitions(${target} PRIVATE QUADSIZE=16)

    if(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
      check_fortran_compiler_flag(-freal-8-real-16 GNU_FORTRAN_SUPPORT_R8R16)
      if(GNU_FORTRAN_SUPPORT_R8R16)
        target_compile_options(${target} PRIVATE -freal-8-real-16)
      endif()
    elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "Intel")
      target_compile_options(${target} PRIVATE -r16)
      target_compile_definitions(${target} PRIVATE DBLE=QEXT)
      target_compile_definitions(${target} PRIVATE DIMAG=QIMAG)
      target_compile_definitions(${target} PRIVATE DCONJG=QCONJG)
      target_compile_definitions(${target} PRIVATE DCMPLX=QCMPLX)
    endif()

    test_big_endian(looptools_big_endian)
    target_compile_definitions(${target} PRIVATE
                               BIGENDIAN=${looptools_big_endian})
  endif()

  target_compile_definitions(${target} PRIVATE U77EXT=0)
  target_compile_definitions(${target} PRIVATE NOUNDERSCORE=0)
endfunction()

if(looptools_build_double)
  add_library(ooptools ${looptools_source})
  target_common_options(ooptools 0)
  install(TARGETS ooptools DESTINATION lib)

  add_executable(lt frontend/lt.F)
  target_common_options(lt 0)
  target_link_libraries(lt ooptools)
  install(TARGETS lt DESTINATION bin)
endif()

if(looptools_build_quad)
  add_library(ooptools-quad ${looptools_source})
  target_common_options(ooptools-quad 16)
  install(TARGETS ooptools-quad DESTINATION lib)

  add_executable(lt-quad frontend/lt.F)
  target_common_options(lt-quad 16)
  target_link_libraries(lt-quad ooptools-quad)
  install(TARGETS lt-quad DESTINATION bin)
endif()
