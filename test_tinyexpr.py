import pytest
import math

import tinyexpr as te


class TestEval:

    def test_simple(self):
        assert te.eval(b'1+1') == 2

    def test_parse_error(self):
        with pytest.raises(SyntaxError, match='position 4'):
            te.eval(b'(5+5')

    def test_non_numbers(self):
        assert te.eval(b'1/0') == float('inf')
        assert math.isnan(te.eval(b'0/0'))
