#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <mozilla/nsCOMPtr.h>
#include <mozilla/xpcom/nsIConsoleService.h>
#include <mozilla/xpcom/nsIConsoleListener.h>
#include <mozilla/xpcom/nsIConsoleMessage.h>
#include <mozilla/xpconnect/nsIScriptError.h>
#include <mozilla/nsIServiceManager.h>
#include <mozilla/string/nsString.h>

static SV *wrap_unichar_string(const PRUnichar *uni_str) {
	const char * u8str;
	NS_ConvertUTF16toUTF8 utf8(uni_str);

	u8str = utf8.get();
	return newSVpv(u8str, 0);
}

class MyListener : public nsIConsoleListener {
public:
	NS_DECL_ISUPPORTS
	NS_DECL_NSICONSOLELISTENER

	SV *callback_;
};

NS_IMPL_ISUPPORTS1(MyListener, nsIConsoleListener)

NS_IMETHODIMP MyListener::Observe(nsIConsoleMessage *msg) {
	dSP;
	PRUnichar *str;
	nsresult rv;
	const nsID id = NS_GET_IID(nsIScriptError);
	nsIScriptError *se = 0;
	SV *psv;
	char *tos = 0;

	msg->QueryInterface(id, (void **) &se);
	rv = se ? se->ToString(&tos) : msg->GetMessage(&str);
	if (NS_FAILED(rv))
		goto out;

	if (tos) {
		psv = newSVpv(tos, 0);
		free(tos);
	} else
		psv = wrap_unichar_string(str);


	ENTER;
	SAVETMPS;
	PUSHMARK(SP);
	XPUSHs(sv_2mortal(psv));
	PUTBACK;
	call_sv(this->callback_, G_DISCARD);
out:
	return rv;
}

MODULE = Mozilla::ConsoleService		PACKAGE = Mozilla::ConsoleService		

int
Register(cb)
	SV *cb;
	INIT:
		nsresult rv;
		nsCOMPtr<nsIConsoleService> os;
		nsCOMPtr<MyListener> lis;
	CODE:
		rv = !NS_OK;
		lis = new MyListener;
		if (!lis)
			goto out_retval;

		os = do_GetService("@mozilla.org/consoleservice;1", &rv);
		if (NS_FAILED(rv))
			goto out_retval;

		rv = os->RegisterListener(lis);
		if (NS_FAILED(rv))
			goto out_retval;

		lis->callback_ = newSVsv(cb);
out_retval:
		RETVAL = (rv == NS_OK);
	OUTPUT:
		RETVAL
