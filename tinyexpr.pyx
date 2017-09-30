#!python
#cython: embedsignature=True
cimport tinyexpr


cpdef double _eval(expression: bytes) except? -9:
    """Evaluate an escii-encoded bytestring expression"""
    cdef:
        int error
        double result

    result = tinyexpr.te_interp(expression, &error)
    if error != 0:
        raise SyntaxError(f'unexpected character at position {error}')
    return result


def eval(expression: str) -> float:
    """Evaluate an expression

    Parameters
    ----------
    expression : str
        The expression string (must be ascii-encodable).

    Returns
    -------
    result : float
        The result of evaluation.

    Raises
    ------
    SyntaxError
        If the expression cannot be parsed

    Examples
    --------

    >>> import tinyexpr as te
    >>> te.eval('sqrt(3^2+4^2)')
    5.0
    >>> te.eval('cos(pi)')
    -1.0
    >>> te.eval('-5/0')
    -inf

    """
    return _eval(expression.encode('ascii'))
