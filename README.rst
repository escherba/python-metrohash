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

.. image:: https://img.shields.io/pypi/pyversions/cityhash.svg
    :target: https://pypi.python.org/pypi/cityhash
    :alt: Supported Python versions

.. image:: https://img.shields.io/pypi/l/cityhash.svg
    :target: https://pypi.python.org/pypi/cityhash
    :alt: License

Getting Started
---------------

To use this package in your program, simply type

.. code-block:: bash

    pip install metrohash


After that, you should be able to import the module and do things with it (see
usage example below).

Usage Examples
--------------

Stateless hashing
~~~~~~~~~~~~~~~~~

This package provides Python interfaces to 64- and 128-bit implementations of
MetroHash algorithm. For stateless hashing, it exports ``metrohash64`` and
``metrohash128`` functions. Both take a value to be hashed and an optional
``seed`` parameter:

.. code-block:: python

    >>> import metrohash
    ...
    >>> metrohash.metrohash64("abc", seed=0)
    17099979927131455419
    >>> metrohash.metrohash128("abc")
    182995299641628952910564950850867298725


Incremental hashing
~~~~~~~~~~~~~~~~~~~

For incremental hashing, use ``MetroHash64`` and ``MetroHash128`` classes.
Incremental hashing is associative and guarantees that any combination of input
slices will result in the same final hash value. This is useful for processing
large inputs and stream data. Example with two slices:

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

Buffer protocol support
~~~~~~~~~~~~~~~~~~~~~~~

The methods in this module support Python `Buffer Protocol
<https://docs.python.org/3/c-api/buffer.html>`__, which allows them to be used
on any object that exports a buffer interface. Here is an example showing
hashing of a 4D NumPy array:

.. code-block:: python

    >>> import numpy as np
    >>> arr = np.zeros((256, 256, 4))
    >>> metrohash.metrohash64(arr)
    12125832280816116063

Note that arrays need to be contiguous for this to work. To convert a
non-contiguous array, use ``np.ascontiguousarray()`` method.

Development
-----------

For those who want to contribute, here is a quick start using some makefile
commands:

.. code-block:: bash

    git clone https://github.com/escherba/python-metrohash.git
    cd python-metrohash
    make env           # creates a Python virtualenv
    make test          # run Python tests
    make cpp-test      # run C++ tests

The Makefiles provided have self-documenting targets. To find out which targets
are available, type:

.. code-block:: bash

    make help

See Also
--------
For other fast non-cryptographic hashing implementations available as Python
extensions, see `CityHash <https://github.com/escherba/python-cityhash>`__ and
`MurmurHash <https://github.com/hajimes/mmh3>`__.

Authors
-------
The MetroHash algorithm and C++ implementation is due to J. Andrew Rogers. The
Python bindings for it were written by Eugene Scherba.

License
-------
This software is licensed under the `Apache License, Version 2.0
<https://opensource.org/licenses/Apache-2.0>`_.  See the included LICENSE
file for details.
