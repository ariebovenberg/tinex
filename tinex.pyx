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
import array


cdef double _eval(bytes expression) except? -1.1:
    """Evaluate an expression and check for errors"""
    cdef:
        int error
        double result = te_interp(expression, &error)

    if error != 0:
        raise ValueError(f'error at position {error}')
    return result



cdef double _eval_with_vars(bytes expression, dict vardict) except? -1.1:
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


def eval(expression, **variables) -> float:
    """Evaluate an expression

    Parameters
    ----------
    expression : str
        The expression string. Must be ascii-encodable.
    **variables : numbers.Real
        values assigned to variables

    Returns
    -------
    result : float
        The result of evaluation.

    Raises
    ------
    ValueError
        If the expression cannot be evaluated
    UnicodeEncodeError
        If the expression or variables cannot be ascii-encoded

    Examples
    --------

    >>> import tinex as te
    >>> te.eval('sqrt(a^2+b^2)', a=3, b=4)
    5.0
    >>> te.eval('cos(pi)')
    -1.0
    >>> te.eval('-5/0')
    -inf

    """
    if isinstance(expression, Expression):
        return _eval_expr(expression,
                          map(variables.__getitem__, expression.varnames))

    cdef bytes expr = (expression.encode('ascii')
                       if isinstance(expression, unicode)
                       else expression)

    if b'\x00' in expr:
        raise ValueError('null byte in expression')

    return _eval_with_vars(expr, variables) if vars else _eval(expr)


cdef class Expression:
    """a compiled expression

    Parameters
    ----------
    body : str
        the text body of the expression
    varnames : str
        variable names as a space-seperated string.

    Example
    -------

    >>> Expression('(sin(42) * alpha) / (beta + 45^3)',
    ...            varnames='beta alpha')
    <Expression: (sin(42) * alpha) / (beta + 45^3)>

    Todos
    -----
    * make threadsafe
    """
    cdef te_expr* _expression
    cdef double* _values
    cpdef readonly tuple varnames
    cpdef readonly str body

    def __cinit__(self, body, varnames):
        cdef:
            list vnames = varnames.split()
            int vcount = len(vnames)
            bytes expr_bytes = body.encode('ascii')
            te_variable *variables = <te_variable *>malloc(
                vcount*sizeof(te_variable))
            int error
            double result
            cdef bytes vname_bytes

        self._values = <double *>malloc(vcount*sizeof(double))

        for i, vname in enumerate(vnames):
            # if len(vname) == 0 or b'\x00' in varname:
            #     raise ValueError(f'invalid variable name: {vname}')
            vname_bytes = vname.encode('ascii')
            variables[i] = te_variable(vname_bytes, &self._values[i], 0, NULL)

        self._expression = te_compile(expr_bytes, variables,
                                      vcount, &error)

        if error != 0:
            raise Exception(error)

        self.varnames = tuple(vnames)
        self.body = body

    def __dealloc__(self):
        te_free(self._expression)
        if self._values != NULL:
            free(self._values)

    def __str__(self):
        return self.body

    def __repr__(self):
        return f'<Expression: {self.body}>'


cdef double _eval_expr(Expression expr, object values):
    for i, val in enumerate(values):
        expr._values[i] = val
    return te_eval(expr._expression)

