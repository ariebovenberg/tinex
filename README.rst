Tinex
=====

.. image:: https://img.shields.io/pypi/v/tinex.svg
    :target: https://pypi.python.org/pypi/tinex

.. image:: https://img.shields.io/pypi/l/tinex.svg
    :target: https://pypi.python.org/pypi/tinex

.. image:: https://img.shields.io/pypi/pyversions/tinex.svg
    :target: https://pypi.python.org/pypi/tinex

.. image:: https://travis-ci.org/ariebovenberg/tinex.svg?branch=master
    :target: https://travis-ci.org/ariebovenberg/tinex

.. image:: https://readthedocs.org/projects/tinex/badge/?version=latest
    :target: http://tinex.readthedocs.io/en/latest/?badge=latest
    :alt: Documentation Status


A python wrapper for tinyexpr_, a mathematical expression parser in C.

.. _tinyexpr: https://codeplea.com/tinyexpr

Quickstart
----------

.. code-block:: python

   >>> import tinex
   >>> tinex.eval('sqrt(a^2+b^2)', a=3, b=4)
   5.0

Installation
------------

.. code-block:: bash

   $ pip install tinex

Documentation
-------------

View the docs here_.

.. _here: http://tinex.readthedocs.io/en/latest/
