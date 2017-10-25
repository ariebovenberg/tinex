Tinex
=====

.. image:: https://travis-ci.org/ariebovenberg/tinex.svg?branch=master
    :target: https://travis-ci.org/ariebovenberg/tinex

A python wrapper for tinyexpr_.

.. _tinyexpr: https://codeplea.com/tinyexpr

Quickstart
----------

.. code-block:: python

   >>> import tinex
   >>> tinex.eval('sqrt(a^2+b^2)', a=3, b=4)
   5.0
