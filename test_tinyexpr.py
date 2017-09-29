import tinyexpr as te


def test_eval():
    assert te.eval(b'1+1') == 2
