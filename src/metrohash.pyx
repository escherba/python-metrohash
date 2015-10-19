#cython: infer_types=True

"""
A Python wrapper for MetroHash, a fast non-cryptographic hashing algorithm
"""

__author__  = "Eugene Scherba"
__email__   = "escherba+metrohash@gmail.com"
__version__ = "0.0.9"
__all__     = [
    "metrohash64", "metrohash64_alt", "metrohash128",
    "CMetroHash64", "CMetroHash128",
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
    cdef uint64 c_Uint128Low64 "Uint128Low64" (uint128& x)
    cdef uint64 c_Uint128High64 "Uint128High64" (uint128& x)
    cdef uint64 c_metrohash64 "metrohash64" (const uint8* buf, uint64 len, uint64 seed)
    cdef uint64 c_bytes2int64 "bytes2int64" (uint8* const array)
    cdef uint128[uint64,uint64] c_bytes2int128 "bytes2int128" (uint8* const array)
    cdef uint128[uint64,uint64] c_metrohash128 "metrohash128" (const uint8* buf, uint64 len, uint64 seed)
    cdef cppclass MetroHash64:
        MetroHash64(const uint64 seed)
        void Initialize(const uint64 seed)
        void Update(const uint8* buf, const uint64 length)
        void Finalize(uint8* const result)
    cdef cppclass MetroHash128:
        MetroHash128(const uint64 seed)
        void Initialize(const uint64 seed)
        void Update(const uint8* buf, const uint64 length)
        void Finalize(uint8* const result)

from cpython.buffer cimport PyObject_CheckBuffer
from cpython.buffer cimport PyBUF_SIMPLE
from cpython.buffer cimport Py_buffer
from cpython.buffer cimport PyObject_GetBuffer

from cpython.unicode cimport PyUnicode_Check

from cpython cimport PyUnicode_AsUTF8String, Py_DECREF


cdef object _type_error(str argname, type expected, value):
    return TypeError(
        "Argument '%s' has incorrect type (expected %s, got %s)" %
        (argname, expected, type(value))
    )


cpdef metrohash64(data, uint64 seed=0):
    """64-bit hash function for a basestring type
    """
    cdef Py_buffer buf
    cdef object obj
    cdef uint64 result
    if PyUnicode_Check(data):
        obj = PyUnicode_AsUTF8String(data)
        PyObject_GetBuffer(obj, &buf, PyBUF_SIMPLE)
        result = c_metrohash64(<const uint8 *>buf.buf, buf.len, seed)
        Py_DECREF(obj)
    elif PyObject_CheckBuffer(data):
        PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
        result = c_metrohash64(<const uint8 *>buf.buf, buf.len, seed)
    else:
        raise _type_error("data", basestring, data)
    return result


cpdef metrohash128(data, uint64 seed=0):
    """128-bit hash function for a basestring type
    """
    cdef Py_buffer buf
    cdef object obj
    cdef pair[uint64, uint64] result
    if PyUnicode_Check(data):
        obj = PyUnicode_AsUTF8String(data)
        PyObject_GetBuffer(obj, &buf, PyBUF_SIMPLE)
        result = c_metrohash128(<const uint8 *>buf.buf, buf.len, seed)
        final = 0x10000000000000000L * long(result.first) + long(result.second)
        Py_DECREF(obj)
    elif PyObject_CheckBuffer(data):
        PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
        result = c_metrohash128(<const uint8 *>buf.buf, buf.len, seed)
        final = 0x10000000000000000L * long(result.first) + long(result.second)
    else:
        raise _type_error("data", basestring, data)
    return final


cdef class CMetroHash64(object):

    """Incremental hasher interface for MetroHash64
    """

    cdef MetroHash64* _m

    def __cinit__(self, uint64 seed=0):
        self._m = new MetroHash64(seed)
        if self._m is NULL:
            raise MemoryError()

    def __dealloc__(self):
        if not self._m is NULL:
            del self._m
            self._m = NULL

    def initialize(self, uint64 seed=0):
        self._m.Initialize(seed)

    def update(self, data):
        cdef Py_buffer buf
        cdef object obj
        if PyUnicode_Check(data):
            obj = PyUnicode_AsUTF8String(data)
            PyObject_GetBuffer(obj, &buf, PyBUF_SIMPLE)
            Py_DECREF(obj)
        elif PyObject_CheckBuffer(data):
            PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
        else:
            raise _type_error("data", basestring, data)
        self._m.Update(<const uint8 *>buf.buf, buf.len)

    def intdigest(self):
        cdef uint8 buf[8]
        self._m.Finalize(buf)
        return c_bytes2int64(buf)


cdef class CMetroHash128(object):

    """Incremental hasher interface for MetroHash128
    """

    cdef MetroHash128* _m

    def __cinit__(self, uint64 seed=0):
        self._m = new MetroHash128(seed)
        if self._m is NULL:
            raise MemoryError()

    def __dealloc__(self):
        if not self._m is NULL:
            del self._m
            self._m = NULL

    def initialize(self, uint64 seed=0):
        self._m.Initialize(seed)

    def update(self, data):
        cdef Py_buffer buf
        cdef object obj
        if PyUnicode_Check(data):
            obj = PyUnicode_AsUTF8String(data)
            PyObject_GetBuffer(obj, &buf, PyBUF_SIMPLE)
            Py_DECREF(obj)
        elif PyObject_CheckBuffer(data):
            PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
        else:
            raise _type_error("data", basestring, data)
        self._m.Update(<const uint8 *>buf.buf, buf.len)

    def intdigest(self):
        cdef uint8 buf[16]
        self._m.Finalize(buf)
        cdef pair[uint64, uint64] result = c_bytes2int128(buf)
        return 0x10000000000000000L * long(result.first) + long(result.second)
