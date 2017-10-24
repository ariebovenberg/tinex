from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

setup(
    name='tinex',
    version='0.1.0',
    description='python wrapper for Tinyexpr',
    author='Arie Bovenberg',
    author_email='a.c.bovenberg@gmail.com',
    ext_modules=cythonize([
        Extension('tinex',
                  ['tinex.pyx'],
                  extra_objects=['tinyexpr/tinyexpr.c'])
        ]),
)
