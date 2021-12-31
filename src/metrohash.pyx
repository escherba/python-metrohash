#cython: infer_types=True
#cython: embedsignature=True
#cython: binding=False
#cython: language_level=2
#distutils: language=c++

"""
Python wrapper for MetroHash, a fast non-cryptographic hashing algorithm
"""

__author__  = "Eugene Scherba"
__email__   = "escherba+metrohash@gmail.com"
__version__ = "0.1.1.post2"
__all__     = [
    "metrohash64",
    "metrohash128",
    "MetroHash64",
    "MetroHash128",
]


cdef extern from * nogil:
    ctypedef unsigned char uint8_t
    ctypedef unsigned long int uint32_t
    ctypedef unsigned long long int uint64_t


cdef extern from "<utility>" namespace "std":
    cdef cppclass pair[T, U]:
        T first
        U second
        pair()
        pair(pair&)
        pair(T&, U&)
        bint operator == (pair&, pair&)
        bint operator != (pair&, pair&)
        bint operator <  (pair&, pair&)
        bint operator >  (pair&, pair&)
        bint operator <= (pair&, pair&)
        bint operator >= (pair&, pair&)


cdef extern from "metro.h" nogil:
    ctypedef uint8_t uint8
    ctypedef uint32_t uint32
    ctypedef uint64_t uint64
    ctypedef pair uint128
    cdef uint64 c_metrohash64 "metrohash64" (const uint8* buf, uint64 length, uint64 seed)
    cdef uint64 c_bytes2int64 "bytes2int64" (uint8* const array)
    cdef uint128[uint64,uint64] c_bytes2int128 "bytes2int128" (uint8* const array)
    cdef uint128[uint64,uint64] c_metrohash128 "metrohash128" (const uint8* buf, uint64 length, uint64 seed)
    cdef cppclass CCMetroHash64 "MetroHash64":
        CCMetroHash64(const uint64 seed)
        void Initialize(const uint64 seed)
        void Update(const uint8* buf, const uint64 length)
        void Finalize(uint8* const result)
        @staticmethod
        void Hash(const uint8_t* buffer, const uint64_t length, uint8_t* const hash, const uint64_t seed)
    cdef cppclass CCMetroHash128 "MetroHash128":
        CCMetroHash128(const uint64 seed)
        void Initialize(const uint64 seed)
        void Update(const uint8* buf, const uint64 length)
        void Finalize(uint8* const result)
        @staticmethod
        void Hash(const uint8_t* buffer, const uint64_t length, uint8_t* const hash, const uint64_t seed)

import sys
from cpython cimport long

from cpython.buffer cimport PyObject_CheckBuffer
from cpython.buffer cimport PyObject_GetBuffer
from cpython.buffer cimport PyBuffer_Release
from cpython.buffer cimport PyBUF_SIMPLE

from cpython.unicode cimport PyUnicode_Check
from cpython.unicode cimport PyUnicode_AsUTF8String

from cpython.bytes cimport PyBytes_Check
from cpython.bytes cimport PyBytes_GET_SIZE
from cpython.bytes cimport PyBytes_AS_STRING


if sys.version_info < (3, ):
    def bytes2hex(bs: bytes) -> str:
        return bs.encode("hex")
else:
    def bytes2hex(bs: bytes) -> str:
        return bs.hex()


cdef object _type_error(argname: str, expected: object, value: object):
    return TypeError(
        "Argument '%s' has incorrect type: expected %s, got '%s' instead" %
        (argname, expected, type(value).__name__)
    )


cpdef bytes hash64(data, uint64_t seed=0ULL):
    """Obtain a 64-bit hash from data using MetroHash-64.
    Args:
        data (str or buffer): input data (either string or buffer type)
        seed (int): seed to random number generator
    Returns:
        bytes: hash value
    Raises:
        TypeError: if input data is not a string or a buffer
        ValueError: if input buffer is not C-contiguous
        OverflowError: if seed cannot be converted to unsigned int64
    """
    cdef Py_buffer buf
    cdef bytes obj
    cdef bytearray out = bytearray(8)
    if PyUnicode_Check(data):
        obj = PyUnicode_AsUTF8String(data)
        PyObject_GetBuffer(obj, &buf, PyBUF_SIMPLE)
        CCMetroHash64.Hash(<const uint8 *>buf.buf, buf.len, out, seed)
        PyBuffer_Release(&buf)
    elif PyBytes_Check(data):
        CCMetroHash64.Hash(
            <const uint8 *>PyBytes_AS_STRING(data),
            PyBytes_GET_SIZE(data), out, seed)
    elif PyObject_CheckBuffer(data):
        PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
        CCMetroHash64.Hash(<const uint8 *>buf.buf, buf.len, out, seed)
        PyBuffer_Release(&buf)
    else:
        raise _type_error("data", ["basestring", "buffer"], data)
    return bytes(out)


cpdef bytes hash128(data, uint64_t seed=0ULL):
    """Obtain a 128-bit hash from data using MetroHash-128.
    Args:
        data (str or buffer): input data (either string or buffer type)
        seed (int): seed to random number generator
    Returns:
        bytes: hash value
    Raises:
        TypeError: if input data is not a string or a buffer
        ValueError: if input buffer is not C-contiguous
        OverflowError: if seed cannot be converted to unsigned int64
    """
    cdef Py_buffer buf
    cdef bytes obj
    cdef bytearray out = bytearray(16)
    if PyUnicode_Check(data):
        obj = PyUnicode_AsUTF8String(data)
        PyObject_GetBuffer(obj, &buf, PyBUF_SIMPLE)
        CCMetroHash128.Hash(<const uint8 *>buf.buf, buf.len, out, seed)
        PyBuffer_Release(&buf)
    elif PyBytes_Check(data):
        CCMetroHash128.Hash(
            <const uint8 *>PyBytes_AS_STRING(data),
            PyBytes_GET_SIZE(data), out, seed)
    elif PyObject_CheckBuffer(data):
        PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
        CCMetroHash128.Hash(<const uint8 *>buf.buf, buf.len, out, seed)
        PyBuffer_Release(&buf)
    else:
        raise _type_error("data", ["basestring", "buffer"], data)
    return bytes(out)


def hash64_hex(data, uint64_t seed=0ULL) -> str:
    """Obtain a 64-bit hash from data using MetroHash-64.
    Args:
        data (str or buffer): input data (either string or buffer type)
        seed (int): seed to random number generator
    Returns:
        str: hash value
    Raises:
        TypeError: if input data is not a string or a buffer
        ValueError: if input buffer is not C-contiguous
        OverflowError: if seed cannot be converted to unsigned int64
    """
    return bytes2hex(hash64(data, seed=seed))


def hash128_hex(data, uint64_t seed=0ULL) -> str:
    """Obtain a 128-bit hash from data using MetroHash-128.
    Args:
        data (str or buffer): input data (either string or buffer type)
        seed (int): seed to random number generator
    Returns:
        str: hash value
    Raises:
        TypeError: if input data is not a string or a buffer
        ValueError: if input buffer is not C-contiguous
        OverflowError: if seed cannot be converted to unsigned int64
    """
    return bytes2hex(hash128(data, seed=seed))


def hash64_int(data, uint64 seed=0ULL) -> int:
    """Obtain a 64-bit hash from data using MetroHash-64.
    Args:
        data (str or buffer): input data (either string or buffer type)
        seed (int): seed to random number generator
    Returns:
        int: hash value
    Raises:
        TypeError: if input data is not a string or a buffer
        ValueError: if input buffer is not C-contiguous
        OverflowError: if seed cannot be converted to unsigned int64
    """
    cdef Py_buffer buf
    cdef bytes obj
    cdef uint64 result
    if PyUnicode_Check(data):
        obj = PyUnicode_AsUTF8String(data)
        PyObject_GetBuffer(obj, &buf, PyBUF_SIMPLE)
        result = c_metrohash64(<const uint8 *>buf.buf, buf.len, seed)
        PyBuffer_Release(&buf)
    elif PyBytes_Check(data):
        result = c_metrohash64(<const uint8 *>PyBytes_AS_STRING(data),
                               PyBytes_GET_SIZE(data), seed)
    elif PyObject_CheckBuffer(data):
        PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
        result = c_metrohash64(<const uint8 *>buf.buf, buf.len, seed)
        PyBuffer_Release(&buf)
    else:
        raise _type_error("data", ["basestring", "buffer"], data)
    return result


def hash128_int(data, uint64 seed=0ULL) -> int:
    """Obtain a 128-bit hash from data using MetroHash-128.
    Args:
        data (str or buffer): input data (either string or buffer type)
        seed (int): seed to random number generator
    Returns:
        int: hash value
    Raises:
        TypeError: if input data is not a string or a buffer
        ValueError: if input buffer is not C-contiguous
        OverflowError: if seed cannot be converted to unsigned int64
    """
    cdef Py_buffer buf
    cdef bytes obj
    cdef pair[uint64, uint64] result
    if PyUnicode_Check(data):
        obj = PyUnicode_AsUTF8String(data)
        PyObject_GetBuffer(obj, &buf, PyBUF_SIMPLE)
        result = c_metrohash128(<const uint8 *>buf.buf, buf.len, seed)
        PyBuffer_Release(&buf)
    elif PyBytes_Check(data):
        result = c_metrohash128(<const uint8 *>PyBytes_AS_STRING(data),
                                PyBytes_GET_SIZE(data), seed)
    elif PyObject_CheckBuffer(data):
        PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
        result = c_metrohash128(<const uint8 *>buf.buf, buf.len, seed)
        PyBuffer_Release(&buf)
    else:
        raise _type_error("data", ["basestring", "buffer"], data)
    return 0x10000000000000000L * long(result.first) + long(result.second)


cdef class MetroHash64(object):
    """Incremental hasher interface for MetroHash-64.

    Args:
        seed (int): seed to random number generator
    Raises:
        TypeError: if seed is not an integer type
        MemoryError: if a new method fails
        OverflowError: if seed is out of bounds
    """

    cdef CCMetroHash64* _m

    def __cinit__(self, uint64 seed=0ULL):
        self._m = new CCMetroHash64(seed)
        if self._m is NULL:
            raise MemoryError()

    def __dealloc__(self):
        if not self._m is NULL:
            del self._m
            self._m = NULL

    def reset(self, uint64 seed=0ULL) -> None:
        """Reset state with a new seed
        Args:
            seed (int): new seed to reset state to
        Raises:
            TypeError: if seed is not an integer type
            OverflowError: if seed is out of bounds
        """
        self._m.Initialize(seed)

    def update(self, data) -> None:
        """Update digest with new data
        Args:
            data (str or buffer): input data (either string or buffer type)
        Raises:
            TypeError: if input data is not a string or a buffer
            ValueError: if input buffer is not C-contiguous
        """
        cdef Py_buffer buf
        cdef bytes obj
        if PyUnicode_Check(data):
            obj = PyUnicode_AsUTF8String(data)
            PyObject_GetBuffer(obj, &buf, PyBUF_SIMPLE)
            self._m.Update(<const uint8 *>buf.buf, buf.len)
            PyBuffer_Release(&buf)
        elif PyBytes_Check(data):
            self._m.Update(<const uint8 *>PyBytes_AS_STRING(data),
                           PyBytes_GET_SIZE(data))
        elif PyObject_CheckBuffer(data):
            PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
            self._m.Update(<const uint8 *>buf.buf, buf.len)
            PyBuffer_Release(&buf)
        else:
            raise _type_error("data", ["basestring", "buffer"], data)

    cpdef bytes digest(self):
        """Obtain bytes digest
        Returns:
            bytes: eight bytes representing the 64-bit hash
        """
        cdef bytearray out = bytearray(8)
        self._m.Finalize(out)
        return bytes(out)

    def hexdigest(self) -> str:
        """Obtain a string digest in hexadecimal form
        Returns:
            bytes: hash string
        """
        return bytes2hex(self.digest())

    def intdigest(self) -> int:
        """Obtain a long integer representing hash value
        Returns:
            int: an integer representing 64-bit hash value
        """
        cdef uint8 buf[8]
        self._m.Finalize(buf)
        return c_bytes2int64(buf)


cdef class MetroHash128(object):
    """Incremental hasher interface for MetroHash-128.

    Args:
        seed (int): seed to random number generator
    Raises:
        TypeError: if seed is not an integer type
        MemoryError: if a new method fails
        OverflowError: if seed is out of bounds
    """

    cdef CCMetroHash128* _m

    def __cinit__(self, uint64 seed=0ULL):
        self._m = new CCMetroHash128(seed)
        if self._m is NULL:
            raise MemoryError()

    def __dealloc__(self):
        if not self._m is NULL:
            del self._m
            self._m = NULL

    def reset(self, uint64 seed=0ULL) -> None:
        """Reset state with a new seed
        Args:
            seed (int): new seed to reset state to
        Raises:
            TypeError: if seed is not an integer type
            OverflowError: if seed is out of bounds
        """
        self._m.Initialize(seed)

    def update(self, data) -> None:
        """Update digest with new data
        Args:
            data (str or buffer): input data (either string or buffer type)
        Raises:
            TypeError: if input data is not a string or a buffer
            ValueError: if input buffer is not C-contiguous
        """
        cdef Py_buffer buf
        cdef bytes obj
        if PyUnicode_Check(data):
            obj = PyUnicode_AsUTF8String(data)
            PyObject_GetBuffer(obj, &buf, PyBUF_SIMPLE)
            self._m.Update(<const uint8 *>buf.buf, buf.len)
            PyBuffer_Release(&buf)
        elif PyBytes_Check(data):
            self._m.Update(<const uint8 *>PyBytes_AS_STRING(data),
                           PyBytes_GET_SIZE(data))
        elif PyObject_CheckBuffer(data):
            PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
            self._m.Update(<const uint8 *>buf.buf, buf.len)
            PyBuffer_Release(&buf)
        else:
            raise _type_error("data", ["basestring", "buffer"], data)

    cpdef bytes digest(self):
        """Obtain bytes digest
        Returns:
            bytes: sixteen bytes representing the 128-bit hash
        """
        cdef bytearray out = bytearray(16)
        self._m.Finalize(out)
        return bytes(out)

    def hexdigest(self) -> str:
        """Obtain a string digest in hexadecimal form
        Returns:
            bytes: hash string
        """
        return bytes2hex(self.digest())

    def intdigest(self) -> int:
        """Obtain integer digest
        Returns:
            int: a long integer representing 128-bit hash value
        """
        cdef uint8 buf[16]
        self._m.Finalize(buf)
        cdef pair[uint64, uint64] result = c_bytes2int128(buf)
        return 0x10000000000000000L * long(result.first) + long(result.second)
