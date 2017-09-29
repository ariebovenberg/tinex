cimport tinyexpr


cpdef double _eval(expression: bytes) except? -1:
    """evaluate an expression"""
    cdef int* error
    return tinyexpr.te_interp(expression, error)


eval = _eval
