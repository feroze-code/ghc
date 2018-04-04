/* -----------------------------------------------------------------------------
 *
 * (c) The GHC Team 1998-2008
 *
 * Generational garbage collector: scavenging functions
 *
 * Documentation on the architecture of the Garbage Collector can be
 * found in the online commentary:
 * 
 *   http://ghc.haskell.org/trac/ghc/wiki/Commentary/Rts/Storage/GC
 *
 * ---------------------------------------------------------------------------*/

#pragma once

#include "BeginPrivate.h"

void    scavenge_loop (void);
void    scavenge_capability_mut_lists (Capability *cap);
void    scavengeTSO (StgTSO *tso);
void    scavenge_stack (StgPtr p, StgPtr stack_end);
void    scavenge_fun_srt (const StgInfoTable *info);
void    scavenge_thunk_srt (const StgInfoTable *info);
StgPtr  scavenge_mut_arr_ptrs (StgMutArrPtrs *a);

#if defined(THREADED_RTS)
void    scavenge_loop1 (void);
void    scavenge_capability_mut_Lists1 (Capability *cap);
void    scavengeTSO1 (StgTSO *tso);
void    scavenge_stack1 (StgPtr p, StgPtr stack_end);
void    scavenge_fun_srt1 (const StgInfoTable *info);
void    scavenge_thunk_srt1 (const StgInfoTable *info);
StgPtr  scavenge_mut_arr_ptrs1 (StgMutArrPtrs *a);
#endif

#include "EndPrivate.h"
