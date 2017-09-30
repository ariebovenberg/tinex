cimport tinyexpr


cpdef double _eval(expression: bytes) except? -9:
    """evaluate an expression"""
    cdef:
        int error
        double result

    result = tinyexpr.te_interp(expression, &error)
    if error != 0:
        raise SyntaxError(f'unexpected character at position {error}')
    return result


eval = _eval
