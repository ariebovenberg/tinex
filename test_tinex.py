import pytest
import math

import tinex as te


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

    @pytest.mark.parametrize('value, result', [
        (0,    5),
        (1,    7),
        (-3.5, -2),
    ])
    def test_with_one_variable(self, value, result):
        assert te.eval('(a*2)+5', dict(a=value)) == result

    @pytest.mark.parametrize('a, beta, result', [
        (0, 0, 0),
        (2, 1, 5),
        (-2.5, 99, 94),
    ])
    def test_with_two_vars(self, a, beta, result):
        assert te.eval('(a*2)+beta', {'beta': beta,
                                      'a': a}) == result
