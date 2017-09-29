cdef extern from "include/tinyexpr.h":
    double te_interp(const char *expression, int *error)
