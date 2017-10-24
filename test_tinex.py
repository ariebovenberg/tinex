# -*- coding: utf-8 -*-
import math

import pytest

import tinex as te

approx = pytest.approx


@pytest.fixture
def expression():
    return 'sqrt(a^2+4^2) / (beta * cos(0.25*pi))'


class TestEvalWithoutVars:

    def test_input_types(self):
        assert te.eval(u'1+1') == 2
        assert te.eval('1+1') == 2
        assert te.eval(te.Expression('3+6')) == 9

    def test_parse_error(self):
        with pytest.raises(ValueError, match='position 4'):
            te.eval('(5+5')

    def test_non_numbers(self):
        assert te.eval('1/0') == float('inf')
        assert math.isnan(te.eval('0/0'))
        assert math.isnan(te.eval('sqrt(-1)'))

    @pytest.mark.parametrize('expr, exception', [
        ('',          ValueError),
        (u'nonåscii', UnicodeEncodeError),
        ('1\x00+1',   ValueError),
    ])
    def test_bad_characters(self, expr, exception):
        with pytest.raises(exception):
            te.eval(expr)


class TestEvalWithVars:

    @pytest.mark.parametrize('expr, variables, result', [
        ('a', dict(a=4.5), 4.5),
        ('(a+2) * beta', {'a': 1, 'beta': 4.5}, 13.5),
        ('((t + 2) * a) / c', dict(t=1.1, a=-1, c=0.2), -15.5)
    ])
    def test_various_inputs(self, expr, variables, result):
        assert te.eval(expr, **variables) == approx(result)

    def test_with_vars_missing_var(self):
        with pytest.raises(ValueError, match='position 16'):
            te.eval('(5 + x1) / 3 + f', x1=4)

    @pytest.mark.parametrize('vname, exception', [
        (u'nonåscii', UnicodeEncodeError),
        ('a\x00lpha', ValueError),
    ])
    def test_bad_characters_in_varnames(self, vname, exception):
        expr = u'{}+4'.format(vname)
        with pytest.raises(exception):
            te.eval(expr, **{vname: 4.5})

    def test_non_numeric_value(self):
        with pytest.raises(TypeError):
            te.eval('a+5', a='not a float')


class TestExpression:

    def test_attributes(self, expression):
        expr = te.Expression(expression, varnames='beta a')

        assert isinstance(expr, te.Expression)
        assert expr.varnames == ('beta', 'a')
        assert expr.body == expression
        assert str(expr) == expression
        assert repr(expr) == '<Expression: {}>'.format(expr)

        with pytest.raises(AttributeError, match='writable'):
            expr.varnames = ('a', 'b')

        with pytest.raises(AttributeError, match='writable'):
            expr.body = 'x + y'

    def test_parse_error(self):
        with pytest.raises(ValueError, match='position 4'):
            te.Expression('(5+5')

    def test_empty_body(self):
        with pytest.raises(ValueError, match='position 1'):
            te.Expression('')

    def test_null_byte_in_body(self):
        with pytest.raises(ValueError, match='null byte'):
            te.Expression('1\x00+1')

    def test_null_byte_in_varname(self):
        with pytest.raises(ValueError, match='null byte'):
            te.Expression('1+alpha * b', 'a\x00lpha b')

    def test_eval_with_kwargs(self, expression):
        expr = te.Expression(expression, varnames='beta a')

        assert te.eval(expr, a=4, beta=9) == approx(.8888888)
        assert te.eval(expr, a=9, beta=-1) == approx(-13.92839)

    def test_eval_missing_var(self, expression):
        expr = te.Expression(expression, varnames='beta a')

        with pytest.raises(TypeError, match='"beta"'):
            te.eval(expr, a=4)
