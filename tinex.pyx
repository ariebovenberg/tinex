#!python
# cython: linetrace=True
# distutils: define_macros=CYTHON_TRACE=1
# cython: embedsignature=True
"""python wrapper for tinyexpr

Todos
-----
* compiled expressions
"""
from tinyexpr cimport (te_interp, te_variable, te_expr, te_compile, te_eval,
                       te_free)
from libc.stdlib cimport malloc, free


cdef double _eval(bytes expression) except? -1.1:
    """Evaluate an expression and check for errors"""
    cdef:
        int error
        double result = te_interp(expression, &error)

    if error != 0:
        raise ValueError(f'error at position {error}')
    return result



cdef double _eval_with_vars(bytes expression, object vardict) except? -1.1:
    """Evalute an expression with variables, check for errors"""
    cdef:
        int varcount = len(vardict)
        te_variable *variables = <te_variable *>malloc(
            varcount*sizeof(te_variable))
        double *values = <double *>malloc(varcount*sizeof(double))
        double result
        int error
        te_expr *expr
        bytes varname

    if not variables or not values:  # pragma: no cover
        raise MemoryError()

    # convert the dict items to `te_variable`s
    try:
        for i, (vname, val) in enumerate(vardict.items()):
            varname = (vname.encode('ascii') if isinstance(vname, unicode)
                       else vname)
            print(type(vname))
            if len(varname) == 0 or b'\x00' in varname:
                raise ValueError(f'invalid variable name: {vname}')
            values[i] = val
            variables[i] = te_variable(varname, &values[i], 0, NULL)
    except Exception:
        free(values)
        free(variables)
        raise

    expr = te_compile(expression, variables, varcount, &error)
    result = te_eval(expr)

    te_free(expr)
    free(values)
    free(variables)

    if error != 0:
        raise ValueError(f'error at position {error}')

    return result


cpdef double eval(object expression, object vars=None) except -1.1:
    """Evaluate an expression

    Parameters
    ----------
    expression : str
        The expression string (must be ascii-encodable).
    vars : Mapping[str, Real]
        mapping of variable names and their assigned values

    Returns
    -------
    result : float
        The result of evaluation.

    Raises
    ------
    ValueError
        If the expression cannot be evaluated
    UnicodeEncodeError
        If the expression cannot be ascii-encoded

    Examples
    --------

    >>> import tinex as te
    >>> te.eval('sqrt(3^2+4^2)')
    5.0
    >>> te.eval('cos(pi)')
    -1.0
    >>> te.eval('-5/0')
    -inf

    """
    cdef bytes expr = (expression.encode('ascii')
                       if isinstance(expression, unicode)
                       else expression)

    if b'\x00' in expr:
        raise ValueError('null byte in expression')

    return _eval_with_vars(expr, vars) if vars else _eval(expr)
