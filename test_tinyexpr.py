import pytest

import tinyexpr as te


class TestEval:

    def test_simple(self):
        assert te.eval(b'1+1') == 2

    def test_parse_error(self):
        with pytest.raises(SyntaxError, match='4'):
            te.eval(b'(5+5')
