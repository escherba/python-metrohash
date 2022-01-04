# MetroHash

Python wrapper for [MetroHash](https://github.com/jandrewrogers/MetroHash), a
fast non-cryptographic hash function.

[![Build Status](https://github.com/escherba/python-metrohash/actions/workflows/build.yml/badge.svg?branch=master)](https://github.com/escherba/python-metrohash/actions/workflows/build.yml)
[![Latest
Version](https://img.shields.io/pypi/v/metrohash.svg)](https://pypi.python.org/pypi/metrohash)
[![Downloads](https://img.shields.io/pypi/dm/metrohash.svg)](https://pypistats.org/packages/metrohash)
[![License](https://img.shields.io/pypi/l/metrohash.svg)](https://pypi.python.org/pypi/metrohash)
[![Supported Python
versions](https://img.shields.io/pypi/pyversions/metrohash.svg)](https://pypi.python.org/pypi/metrohash)

## Getting Started

To use this package in your program, simply type

``` bash
pip install metrohash
```

After that, you should be able to import the module and do things with
it (see usage example below).

## Usage Examples

### Stateless hashing

This package provides Python interfaces to 64- and 128-bit
implementations of MetroHash algorithm. For stateless hashing, it
exports `metrohash64` and `metrohash128` functions. Both take a value to
be hashed and an optional `seed` parameter:

``` python
>>> import metrohash
...
>>> metrohash.hash64_int("abc", seed=0)
17099979927131455419
>>> metrohash.hash128_int("abc")
182995299641628952910564950850867298725

```

### Incremental hashing

Unlike its cousins CityHash and FarmHash, MetroHash allows incremental
(stateful) hashing. For incremental hashing, use `MetroHash64` and
`MetroHash128` classes. Incremental hashing is associative and
guarantees that any combination of input slices will result in the same
final hash value. This is useful for processing large inputs and stream
data. Example with two slices:

``` python
>>> mh = metrohash.MetroHash64()
>>> mh.update("Nobody inspects")
>>> mh.update(" the spammish repetition")
>>> mh.intdigest()
7851180100622203313

```

The resulting hash value above should be the same as in:

``` python
>>> mh = metrohash.MetroHash64()
>>> mh.update("Nobody inspects the spammish repetition")
>>> mh.intdigest()
7851180100622203313

```

### Fast hashing of NumPy arrays

The Python [Buffer
Protocol](https://docs.python.org/3/c-api/buffer.html) allows Python
objects to expose their data as raw byte arrays to other objects, for
fast access without copying to a separate location in memory. Among
others, NumPy is a major framework that supports this protocol.

All hashing functions in this packege will read byte arrays from objects
that expose them via the buffer protocol. Here is an example showing
hashing of a 4D NumPy array:

``` python
>>> import numpy as np
>>> arr = np.zeros((256, 256, 4))
>>> metrohash.hash64_int(arr)
12125832280816116063

```

The arrays need to be contiguous for this to work. To convert a
non-contiguous array, use NumPy's `ascontiguousarray()` function.

## Development

### Local workflow

For those who want to contribute, here is a quick start using some
makefile commands:

``` bash
git clone https://github.com/escherba/python-metrohash.git
cd python-metrohash
make env           # create a Python virtualenv
make test          # run Python tests
make cpp-test      # run C++ tests
make shell         # enter IPython shell
```

To find out which Make targets are available, type:

``` bash
make help
```

### Distribution

The wheels are built using [cibuildwheel](https://cibuildwheel.readthedocs.io/)
and are distributed to PyPI using GitHub actions. The wheels contain compiled
binaries and are available for the following platforms: windows-amd64,
ubuntu-x86, linux-x86\_64, linux-aarch64, and macosx-x86\_64.

## See Also

For other fast non-cryptographic hash functions available as Python
extensions, see [FarmHash](https://github.com/escherba/python-cityhash)
and [MurmurHash](https://github.com/hajimes/mmh3).

## Authors

The MetroHash algorithm and C++ implementation is due to J. Andrew
Rogers. The Python bindings for it were written by Eugene Scherba.

## License

This software is licensed under the [Apache License,
Version 2.0](https://opensource.org/licenses/Apache-2.0). See the
included LICENSE file for details.
