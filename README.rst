MetroHash
=========

A Python wrapper around `MetroHash <https://github.com/jandrewrogers/MetroHash>`__

.. image:: https://travis-ci.org/escherba/python-metrohash.svg
    :target: https://travis-ci.org/escherba/python-metrohash


Installation
------------

To get started, clone this repo and run `make env` or alternatively
install it into your environment of choice (below). Note that you
will need to have Cython installed before you install this package.

.. code-block:: bash

    pip install -U cython
    pip install git+https://github.com/escherba/metrohash#egg=metrohash-0.0.1


Example Usage
-------------

The module provides Python interfaces to 64- and 128-bit implementations
of MetroHash algorithm:

.. code-block:: python

    >>> import metrohash
    ...
    >>> metrohash.metrohash64("abc")
    17099979927131455419L
    >>> metrohash.metrohash128("abc")
    (9920195071304498087L, 2078520654167540133L)


For incremental hashing, use CMetroHash classes:

.. code-block:: python

    >>> mh = metrohash.CMetroHash64()
    >>> mh.update("abc")
    >>> mh.update("def")
    >>> mh.finalize()
    3528379674302886064L

Note that the resulting hash value above is the same as:

.. code-block:: python

    >>> mh = metrohash.CMetroHash64()
    >>> mh.update("abcdef")
    >>> mh.finalize()
    3528379674302886064L
