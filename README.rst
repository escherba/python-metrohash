MetroHash
=========

A Python wrapper around `MetroHash <https://github.com/jandrewrogers/MetroHash>`__

.. image:: https://travis-ci.org/escherba/python-metrohash.svg
    :target: https://travis-ci.org/escherba/python-metrohash


Installation
------------

To get started, clone this repo and run ``make env`` or, alternatively,
install it into your environment of choice (below). Note that you
will need to have Cython installed before you install this package.

.. code-block:: bash

    pip install -U cython
    pip install git+https://github.com/escherba/metrohash


Example Usage
-------------

This package provides Python interfaces to 64- and 128-bit implementations
of MetroHash algorithm. For stateless hashing, it exports `metrohash64` and
``metrohash128`` functions. Each has an optional ``seed`` parameter.

.. code-block:: python

    >>> import metrohash
    ...
    >>> metrohash.metrohash64("abc", seed=0)
    17099979927131455419L
    >>> metrohash.metrohash128("abc")
    182995299641628952910564950850867298725L


For incremental hashing, use ``CMetroHash64`` and ``CMetroHash128`` classes.
Incremental hashing is associative and guarantees that any combination of
input slices will result in the same final hash value. This is useful for
processing large inputs and stream data.

.. code-block:: python

    >>> mh = metrohash.CMetroHash64()
    >>> mh.update("Nobody inspects")
    >>> mh.update(" the spammish repetition")
    >>> mh.finalize()
    7851180100622203313L

Note that the resulting hash value above is the same as:

.. code-block:: python

    >>> mh = metrohash.CMetroHash64()
    >>> mh.update("Nobody inspects the spammish repetition")
    >>> mh.finalize()
    7851180100622203313L
