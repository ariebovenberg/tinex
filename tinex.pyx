#!python
#cython: embedsignature=True
"""python wrapper for tinyexpr

Todos
-----
* pre-compiled expressions
* test non-dict mappings
* test input edge-cases
"""
from tinyexpr cimport (te_interp, te_variable, te_expr, te_compile, te_eval,
                       te_free)
from libc.stdlib cimport malloc, free


cdef double _eval(bytes expression) except? -9:
    """Evaluate an expression and check for errors"""
    cdef:
        int error
        double result = te_interp(expression, &error)

    if error != 0:
        raise SyntaxError(f'unexpected character at position {error}')
    return result



cdef double _eval_with_vars(bytes expression, dict vardict) except? -9:
    """Evalute an expression with variables, check for errors"""
    cdef:
        int varcount = len(vardict)
        te_variable *variables = <te_variable *>malloc(
            varcount*sizeof(te_variable))
        double *values = <double *>malloc(varcount*sizeof(double))
        double result
        int error
        te_expr *expr

    if not variables or not values:  # pragma: no cover
        raise MemoryError()

    # convert the dict items to `te_variable`s
    for i, (vname, val) in enumerate(vardict.items()):
        values[i] = val
        variables[i] = te_variable(vname.encode('ascii'), &values[i], 0, NULL)

    expr = te_compile(expression, variables, varcount, &error)
    result = te_eval(expr)

    te_free(expr)
    free(values)
    free(variables)

    if error != 0:
        raise SyntaxError(f'error at position {error}')

    return result


def eval(str expression, dict vars=None) -> float:
    """Evaluate an expression

    Parameters
    ----------
    expression : str
        The expression string (must be ascii-encodable).
    vars : dict[str, float]
        mapping of variable names and their assigned values

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

    >>> import tinex as te
    >>> te.eval('sqrt(3^2+4^2)')
    5.0
    >>> te.eval('cos(pi)')
    -1.0
    >>> te.eval('-5/0')
    -inf

    """
    expr = expression.encode('ascii')
    return _eval(expr) if vars is None else _eval_with_vars(expr, vars)
