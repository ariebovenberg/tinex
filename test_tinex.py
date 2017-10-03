# -*- coding: utf-8 -*-
from __future__ import unicode_literals
import math
from collections import Counter

import pytest

import tinex as te

approx = pytest.approx


class TestEval:

    def test_simple(self):
        assert te.eval('1+1') == 2
        assert te.eval(b'1+1') == 2

    def test_parse_error(self):
        with pytest.raises(ValueError, match='position 4'):
            te.eval('(5+5')

    def test_non_numbers(self):
        assert te.eval('1/0') == float('inf')
        assert math.isnan(te.eval('0/0'))
        assert math.isnan(te.eval('sqrt(-1)'))

    @pytest.mark.parametrize('expr, vars, result', [
        ('a', dict(a=4.5), 4.5),
        ('(a+2) * beta', {b'a': 1, 'beta': 4.5}, 13.5),
        ('((t + 2) * a) / c', dict(t=1.1, a=-1, c=0.2), -15.5)
    ])
    def test_with_vars(self, expr, vars, result):
        assert te.eval(expr, vars=vars) == approx(result)

    def test_supports_any_mapping(self):
        assert te.eval('a+3', Counter(a=-1.2)) == approx(1.8)

    def test_with_vars_missing_var(self):
        with pytest.raises(ValueError, match='position 16'):
            te.eval('(5 + x1) / 3 + f', dict(x1=4))

    @pytest.mark.parametrize('expr, exception', [
        ('',         ValueError),
        ('nonåscii', UnicodeEncodeError),
        ('1\x00+1',  ValueError),
    ])
    def test_bad_characters(self, expr, exception):
        with pytest.raises(exception):
            te.eval(expr)

    @pytest.mark.parametrize('vname, exception', [
        ('',          ValueError),
        ('nonåscii',  UnicodeEncodeError),
        ('a\x00lpha', ValueError),
    ])
    def test_bad_characters_in_varnames(self, vname, exception):
        expr = '{}+4'.format(vname)
        with pytest.raises(exception):
            te.eval(expr, {vname: 4.5})

    def test_non_numeric_value(self):
        with pytest.raises(TypeError):
            te.eval('a+5', dict(a='not a float'))
