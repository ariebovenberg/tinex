import pytest
import math

import tinyexpr as te


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
