// this is the top level file for the febex config
// the configuration will be processed by a C-preprocessor,
// then the output is fed to setpar. 

add sfp 4

// write your modules here:
add module 0 20

#include "default/base.h" // base config for febex 
#include "default/trigmode/single_self.h"

#define BOOST 
#ifndef BOOST // easy variant ///////////////////////////////////////////////
#define SET_PROTON_RANGE(MOD) set MOD .*.discr_threshold_gamma 100 ; set MOD .*.discr_threshold_timing 50

SET_PROTON_RANGE(0.1);
SET_PROTON_RANGE(0.2);

#else //BOOST variant ///////////////////////////////////////////////////////

#include <boost/preprocessor/seq/for_each.hpp>

#define PROTON_RANGE_MODULES (0.1)(0.3)(0.5)
#define BOOST_SET_PROTON_RANGE(r, data, MOD)	\
  set MOD.*.discr_threshold_gamma 444 ;		\
  set MOD.*.discr_threshold_timing  111 ;

BOOST_PP_SEQ_FOR_EACH(BOOST_SET_PROTON_RANGE, _, PROTON_RANGE_MODULES )
#endif //BOOST //////////////////////////////////////////////////////////////

#include "thresholds.h"
