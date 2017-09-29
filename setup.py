from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

setup(
    ext_modules=cythonize([Extension('tinyexpr',
                                     ['tinyexpr.pyx'],
                                     extra_objects=['include/tinyexpr.c']
                                     )])
)
