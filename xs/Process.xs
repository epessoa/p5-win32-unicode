#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <windows.h>

MODULE = Win32::Unicode::Process  PACKAGE = Win32::Unicode::Process

PROTOTYPES: DISABLE

long
wait_for_single_object(long handle)
    CODE:
        RETVAL = WaitForSingleObject(handle, INFINITE);
    OUTPUT:
        RETVAL

long
wait_for_input_idle(long handle)
    CODE:
        RETVAL = WaitForInputIdle(handle, INFINITE);
    OUTPUT:
        RETVAL

SV*
create_process(SV* shell, SV* cmd)
    CODE:
        STRLEN              len;
        const WCHAR*        cshell = SvPV_const(shell, len);
        WCHAR*              ccmd = SvPV(cmd, len);
        STARTUPINFOW        si;
        PROCESS_INFORMATION pi;
        
        ZeroMemory(&si,sizeof(si));
        si.cb=sizeof(si);
        
        if (CreateProcessW(
            cshell,
            ccmd,
            NULL,
            NULL,
            FALSE,
            NORMAL_PRIORITY_CLASS,
            NULL,
            NULL,
            &si,
            &pi
        ) == 0) {
            XSRETURN_EMPTY;
        }
        
        SV* sv = newSV(0);
        HV* hv = newHV();
        sv_setsv(sv, sv_2mortal(newRV_noinc((SV*)hv)));
        hv_store(hv, "thread_handle", strlen("thread_handle"), newSViv(pi.hThread), 0);
        hv_store(hv, "process_handle", strlen("process_handle"), newSViv(pi.hProcess), 0);
        
        RETVAL = sv;
    OUTPUT:
        RETVAL
