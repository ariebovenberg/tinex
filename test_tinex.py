import pytest
import math

import tinex as te

approx = pytest.approx


class TestEval:

    def test_simple(self):
        assert te.eval('1+1') == 2

    def test_parse_error(self):
        with pytest.raises(SyntaxError, match='position 4'):
            te.eval('(5+5')

    def test_non_numbers(self):
        assert te.eval('1/0') == float('inf')
        assert math.isnan(te.eval('0/0'))
        assert math.isnan(te.eval('sqrt(-1)'))

    @pytest.mark.parametrize('expr, vars, result', [
        ('a', dict(a=4.5), 4.5),
        ('(a+2) * beta', dict(a=1, beta=4.5), 13.5),
        ('((t + 2) * a) / c', dict(t=1.1, a=-1, c=0.2), -15.5)
    ])
    def test_with_vars(self, expr, vars, result):
        assert te.eval(expr, vars=vars) == approx(result)

    def test_with_vars_missing_var(self):
        with pytest.raises(SyntaxError, match='position 16'):
            te.eval('(5 + x1) / 3 + f', dict(x1=4))
