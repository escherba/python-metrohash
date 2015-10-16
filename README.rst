MetroHash
========

This is a Python wrapper around a C implementation of MetroHash, a fast non-cryptographic hashing algorithm.

To get started, clone this repo and run the setup.py script, or, alternatively

.. code-block:: bash

    pip install -U cython
    pip install git+https://github.com/escherba/metrohash#egg=metrohash-0.0.1


MetroHash64
----------

64-bit implementation of MetroHash algorithm

.. code-block:: python

    >>> import metrohash
    ...
    >>> metrohash.metrohash64("abc")
    17099979927131455419L
    >>> metrohash.metrohash128("abc")
    (9920195071304498087L, 2078520654167540133L)


For incremental hashing, use CMetroHash classes:

.. code-block:: python

    >>> import metrohash
    ...
    >>> mh = metrohash.CMetroHash64()
    >>> mh.update("abc")
    >>> mh.update("def")
    >>> mh.finalize()
    3528379674302886064L

    >>> mh = metrohash.CMetroHash64()
    >>> mh.update("abcdef")
    >>> mh.finalize()
    3528379674302886064L
