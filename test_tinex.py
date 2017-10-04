# -*- coding: utf-8 -*-
import math

import pytest

import tinex as te

approx = pytest.approx


class TestEval:

    def test_simple(self):
        assert te.eval(u'1+1') == 2
        assert te.eval(b'1+1') == 2

    def test_parse_error(self):
        with pytest.raises(ValueError, match='position 4'):
            te.eval('(5+5')

    def test_non_numbers(self):
        assert te.eval('1/0') == float('inf')
        assert math.isnan(te.eval('0/0'))
        assert math.isnan(te.eval('sqrt(-1)'))

    @pytest.mark.parametrize('expr, variables, result', [
        ('a', dict(a=4.5), 4.5),
        ('(a+2) * beta', {'a': 1, 'beta': 4.5}, 13.5),
        ('((t + 2) * a) / c', dict(t=1.1, a=-1, c=0.2), -15.5)
    ])
    def test_with_vars(self, expr, variables, result):
        assert te.eval(expr, **variables) == approx(result)

    def test_with_vars_missing_var(self):
        with pytest.raises(ValueError, match='position 16'):
            te.eval('(5 + x1) / 3 + f', x1=4)

    @pytest.mark.parametrize('expr, exception', [
        ('',         ValueError),
        (u'nonåscii', UnicodeEncodeError),
        ('1\x00+1',  ValueError),
    ])
    def test_bad_characters(self, expr, exception):
        with pytest.raises(exception):
            te.eval(expr)

    @pytest.mark.parametrize('vname, exception', [
        ('',          ValueError),
        (u'nonåscii',  UnicodeEncodeError),
        ('a\x00lpha', ValueError),
    ])
    def test_bad_characters_in_varnames(self, vname, exception):
        expr = u'{}+4'.format(vname)
        with pytest.raises(exception):
            te.eval(expr, **{vname: 4.5})

    def test_non_numeric_value(self):
        with pytest.raises(TypeError):
            te.eval('a+5', a='not a float')
