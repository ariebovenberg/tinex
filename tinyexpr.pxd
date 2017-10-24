cdef extern from "tinyexpr/tinyexpr.h":
    double te_interp(const char *expression, int *error)

    ctypedef struct te_expr:
        int type
        # the following 3 fields are part of an anonymous union
        double value
        const double *bound
        const void *function
        void *parameters[1]

    ctypedef struct te_variable:
        const char *name
        const void *address
        int type
        void *context

    te_expr *te_compile(const char *expression,
                        const te_variable *variables,
                        int var_count, int *error)

    double te_eval(const te_expr *expr)

    void te_free(te_expr *expr)
