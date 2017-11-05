import os
from setuptools import setup
from distutils.extension import Extension
from distutils.command.sdist import sdist as _sdist

USE_CYTHON = os.environ.get('TINEX_USE_CYTHON', False)


class sdist(_sdist):

    def run(self):
        # make sure the cython-built files are up-to-date
        from Cython.Build import cythonize
        cythonize(Extension('tinex', ['tinex.pyx'],
                            extra_objects=['tinyexpr/tinyexpr.c']))
        _sdist.run(self)


cmdclass = {'sdist': sdist}

if USE_CYTHON:
    from Cython.Build import build_ext
    extension_file = 'tinex.pyx'
    cmdclass['build_ext'] = build_ext
else:
    extension_file = 'tinex.c'


setup(
    name='tinex',
    version='0.3.0',
    description='Python wrapper for Tinyexpr',
    author='Arie Bovenberg',
    author_email='a.c.bovenberg@gmail.com',
    url='https://github.com/ariebovenberg/tinex',
    license='MIT',
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
    ext_modules=[
        Extension('tinex', [extension_file],
                  extra_objects=['tinyexpr/tinyexpr.c'])
    ],
    cmdclass=cmdclass
)
