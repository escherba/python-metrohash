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

    >>> from metrohash import MetroHash64
    >>> MetroHash64("abc")
    17099979927131455419L

