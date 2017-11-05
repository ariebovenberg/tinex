#!python
# cython: linetrace=True
# distutils: define_macros=CYTHON_TRACE=1
# cython: embedsignature=True
"""python wrapper for tinyexpr"""
from tinyexpr cimport (te_interp, te_variable, te_expr, te_compile, te_eval,
                       te_free)
from libc.stdlib cimport malloc, free
cimport cpython.array
import array


cdef double _eval_static(bytes expression) except? -1.1:
    """evalate a static expression (without variables)"""
    if b'\x00' in expression:
        raise ValueError('null byte in variable name')
    cdef:
        int error
        double result = te_interp(expression, &error)

    if error != 0:
        raise ValueError(f'error at position {error}')
    return result


def eval(expression, **variables) -> float:
    """Evaluate an expression

    Parameters
    ----------
    expression : Expression or str
        The expression. If a string, it must be ascii-encodable.
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
    cdef double[:] vars_
    if isinstance(expression, Expression):
        try:
            vars_ = array.array('d', map(variables.__getitem__,
                                         expression.varnames))
        except KeyError as e:
            raise TypeError(f'missing variable "{e.args[0]}"')

        return _eval_expr(expression, vars_)
    elif not variables:
        return _eval_static(expression.encode('ascii'))
    else:
        return eval(Expression(expression, varnames=' '.join(variables)),
                    **variables)


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

    Todo
    ----
    * make evaluation threadsafe
    * implement evaluate with positional args
    """
    cdef te_expr* _expression
    cdef double* _values
    cpdef readonly tuple varnames
    cpdef readonly str body

    def __cinit__(self, body, varnames=''):
        cdef:
            list vnames = varnames.encode('ascii').split()
            int vcount = len(vnames)
            bytes expr_bytes = body.encode('ascii')
            te_variable *variables = <te_variable *>malloc(
                vcount*sizeof(te_variable))
            int error
            double result
            cdef bytes vname_bytes

        if b'\x00' in expr_bytes:
            raise ValueError('null byte in expression body')

        self._values = <double *>malloc(vcount*sizeof(double))

        for i, vname in enumerate(vnames):
            if b'\x00' in vname:
                raise ValueError('null byte in variable name')
            variables[i] = te_variable(vname, &self._values[i], 0, NULL)

        self._expression = te_compile(expr_bytes, variables,
                                      vcount, &error)

        if error != 0:
            raise ValueError(f'error at position {error}')

        self.varnames = tuple(varnames.split())
        self.body = body

    def __dealloc__(self):
        te_free(self._expression)
        if self._values != NULL:
            free(self._values)

    def __str__(self):
        return self.body

    def __repr__(self):
        return f'<Expression: {self.body}>'


cdef double _eval_expr(Expression expr, double[:] values) except? 1.1:
    for i, val in enumerate(values):
        expr._values[i] = val
    return te_eval(expr._expression)

