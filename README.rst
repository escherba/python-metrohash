MetroHash
=========

A Python wrapper around `MetroHash <https://github.com/jandrewrogers/MetroHash>`__

.. image:: https://img.shields.io/pypi/v/metrohash.svg
    :target: https://pypi.python.org/pypi/metrohash
    :alt: Latest Version

.. image:: https://img.shields.io/pypi/dm/metrohash.svg
    :target: https://pypi.python.org/pypi/metrohash
    :alt: Downloads

.. image:: https://circleci.com/gh/escherba/python-metrohash.png?style=shield
    :target: https://circleci.com/gh/escherba/python-metrohash
    :alt: Tests Status

Getting Started
---------------

To use this package in your program, simply enter

.. code-block:: bash

    pip install metrohash


After that, you should be able to import the module and do things with it (see
Example Usage below).

Example Usage
-------------

This package provides Python interfaces to 64- and 128-bit implementations
of MetroHash algorithm. For stateless hashing, it exports ``metrohash64`` and
``metrohash128`` functions. Both take a value to be hashed (either string or unicode) and
an optional ``seed`` parameter:

.. code-block:: python

    >>> import metrohash
    ...
    >>> metrohash.metrohash64("abc", seed=0)
    17099979927131455419
    >>> metrohash.metrohash128("abc")
    182995299641628952910564950850867298725


For incremental hashing, use ``MetroHash64`` and ``MetroHash128`` classes.
Incremental hashing is associative and guarantees that any combination of
input slices will result in the same final hash value. This is useful for
processing large inputs and stream data. Example with two slices:

.. code-block:: python

    >>> mh = metrohash.MetroHash64()
    >>> mh.update("Nobody inspects")
    >>> mh.update(" the spammish repetition")
    >>> mh.intdigest()
    7851180100622203313

Note that the resulting hash value above is the same as in:

.. code-block:: python

    >>> mh = metrohash.MetroHash64()
    >>> mh.update("Nobody inspects the spammish repetition")
    >>> mh.intdigest()
    7851180100622203313


Development
-----------

If you want to contribute to this package by developing, the included Makefile
provides some useful commands to help with that task:

.. code-block:: bash

    git clone https://github.com/escherba/python-metrohash.git
    cd python-metrohash
    make env           # creates a Python virtualenv
    make test          # builds and runs C++ and Python tests


See Also
--------
For other fast non-cryptographic hashing implementations available as Python extensions, see `CityHash <https://github.com/escherba/python-cityhash>`__ and `xxh <https://github.com/lebedov/xxh>`__.

Authors
-------
The original MetroHash algorithm was designed by J. Andrew Rogers. The Python bindings in this package were written by Eugene Scherba.

License
-------
This software is licensed under the `MIT License
<http://www.opensource.org/licenses/mit-license>`_.
See the included LICENSE file for more information.
