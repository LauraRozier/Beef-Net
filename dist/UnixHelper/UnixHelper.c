#include <errno.h>

#ifdef __cplusplus
extern "C" {
#endif

	int UnixHelper_geterrno() { return errno; }
	void UnixHelper_seterrno(int errnum) { errno = errnum; }

#ifdef __cplusplus
}
#endif
