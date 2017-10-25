from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

setup(
    name='tinex',
    version='0.1.0',
    description='python wrapper for Tinyexpr',
    author='Arie Bovenberg',
    author_email='a.c.bovenberg@gmail.com',
    classifiers=[
        'Development Status :: 4 - Beta',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: MIT License',

        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.4',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',

    ],
    ext_modules=cythonize([
        Extension('tinex',
                  ['tinex.pyx'],
                  extra_objects=['tinyexpr/tinyexpr.c'])
        ]),
)
