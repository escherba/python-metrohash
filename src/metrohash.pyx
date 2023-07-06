#cython: infer_types=True
#cython: embedsignature=True
#cython: binding=False
#cython: language_level=3
#distutils: language=c++

"""
Python wrapper for MetroHash, a fast non-cryptographic hashing algorithm
"""

__author__  = "Eugene Scherba"
__email__   = "escherba+metrohash@gmail.com"
__version__ = "0.3.3"
__all__     = [
    "MetroHash64",
    "MetroHash128",
    "hash64",
    "hash128",
    "hash64_int",
    "hash128_int",
    "hash64_hex",
    "hash128_hex",
]


cdef extern from * nogil:
    ctypedef unsigned char uint8_t
    ctypedef unsigned long int uint32_t
    ctypedef unsigned long long int uint64_t


cdef extern from "<utility>" namespace "std" nogil:
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


cdef extern from "Python.h":
    # Note that following functions can potentially raise an exception,
    # thus they cannot be declared 'nogil'. Also, PyUnicode_AsUTF8AndSize() can
    # potentially allocate memory inside in unlikely case of when underlying
    # unicode object was stored as non-utf8 and utf8 wasn't requested before.
    const char* PyUnicode_AsUTF8AndSize(object obj, Py_ssize_t* length) except NULL


cdef extern from "metro.h" nogil:
    ctypedef uint8_t uint8
    ctypedef uint32_t uint32
    ctypedef uint64_t uint64
    ctypedef pair[uint64, uint64] uint128
    cdef uint64 c_metrohash64 "metrohash64" (const uint8* key, uint64 length, uint64 seed)
    cdef uint64 c_bytes2int64 "bytes2int64" (uint8* const array)
    cdef uint128 c_bytes2int128 "bytes2int128" (uint8* const array)
    cdef uint128 c_metrohash128 "metrohash128" (const uint8* key, uint64 length, uint64 seed)
    cdef cppclass CCMetroHash64 "MetroHash64":
        CCMetroHash64(const uint64 seed)
        void Initialize(const uint64 seed)
        void Update(const uint8* key, const uint64 length)
        void Finalize(uint8* const result)
        @staticmethod
        void Hash(const uint8* key, const uint64 length, uint8* const out, const uint64 seed)
    cdef cppclass CCMetroHash128 "MetroHash128":
        CCMetroHash128(const uint64 seed)
        void Initialize(const uint64 seed)
        void Update(const uint8* key, const uint64 length)
        void Finalize(uint8* const result)
        @staticmethod
        void Hash(const uint8* key, const uint64 length, uint8* const out, const uint64 seed)


from cpython cimport long

from cpython.buffer cimport PyObject_CheckBuffer
from cpython.buffer cimport PyObject_GetBuffer
from cpython.buffer cimport PyBuffer_Release
from cpython.buffer cimport PyBUF_SIMPLE

from cpython.unicode cimport PyUnicode_Check

from cpython.bytes cimport PyBytes_Check
from cpython.bytes cimport PyBytes_GET_SIZE
from cpython.bytes cimport PyBytes_AS_STRING


cdef inline str bytes2hex(bytes bs):
    return bs.hex()


cdef object _type_error(argname: str, expected: object, value: object):
    return TypeError(
        "Argument '%s' has incorrect type: expected %s, got '%s' instead" %
        (argname, expected, type(value).__name__)
    )


cpdef bytes hash64(data, uint64 seed=0ULL):
    """Obtain a 64-bit hash from data using MetroHash-64.

    :param data: input data (either string or buffer type)
    :param seed: seed to random number generator (integer)
    :return: hash value (bytes)
    :raises TypeError: if input data is not a string or a buffer
    :raises ValueError: if input buffer is not C-contiguous
    :raises OverflowError: if seed cannot be converted to unsigned int64
    """
    cdef Py_buffer buf
    cdef bytearray out = bytearray(8)
    cdef const char* encoding
    cdef Py_ssize_t encoding_size = 0

    if PyUnicode_Check(data):
        encoding = PyUnicode_AsUTF8AndSize(data, &encoding_size)
        CCMetroHash64.Hash(<const uint8*>encoding, encoding_size, out, seed)
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


cpdef bytes hash128(data, uint64 seed=0ULL):
    """Obtain a 128-bit hash from data using MetroHash-128.

    :param data: input data (either string or buffer type)
    :param seed: seed to random number generator (integer)
    :return: hash value (bytes)
    :raises TypeError: if input data is not a string or a buffer
    :raises ValueError: if input buffer is not C-contiguous
    :raises OverflowError: if seed cannot be converted to unsigned int64
    """
    cdef Py_buffer buf
    cdef bytearray out = bytearray(16)
    cdef const char* encoding
    cdef Py_ssize_t encoding_size = 0

    if PyUnicode_Check(data):
        encoding = PyUnicode_AsUTF8AndSize(data, &encoding_size)
        CCMetroHash128.Hash(<const uint8*>encoding, encoding_size, out, seed)
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



def hash64_hex(data, uint64 seed=0ULL) -> str:
    """Obtain a 64-bit hash from data using MetroHash-64.

    :param data: input data (either string or buffer type)
    :param seed: seed to random number generator (integer)
    :return: hash value (string)
    :raises TypeError: if input data is not a string or a buffer
    :raises ValueError: if input buffer is not C-contiguous
    :raises OverflowError: if seed cannot be converted to unsigned int64
    """
    return bytes2hex(hash64(data, seed=seed))


def hash128_hex(data, uint64 seed=0ULL) -> str:
    """Obtain a 128-bit hash from data using MetroHash-128.

    :param data: data (either string or buffer type)
    :param seed: seed to random number generator (integer)
    :return: hash value (string)
    :raises TypeError: if input data is not a string or a buffer
    :raises ValueError: if input buffer is not C-contiguous
    :raises OverflowError: if seed cannot be converted to unsigned int64
    """
    return bytes2hex(hash128(data, seed=seed))


def hash64_int(data, uint64 seed=0ULL) -> int:
    """Obtain a 64-bit hash from data using MetroHash-64.

    :param data: input data (either string or buffer type)
    :param seed: seed to random number generator (integer)
    :return: hash value (integer)
    :raises TypeError: if input data is not a string or a buffer
    :raises ValueError: if input buffer is not C-contiguous
    :raises OverflowError: if seed cannot be converted to unsigned int64
    """
    cdef Py_buffer buf
    cdef uint64 result
    cdef const char* encoding
    cdef Py_ssize_t encoding_size = 0

    if PyUnicode_Check(data):
        encoding = PyUnicode_AsUTF8AndSize(data, &encoding_size)
        result = c_metrohash64(<const uint8 *>encoding, encoding_size, seed)
    elif PyBytes_Check(data):
        result = c_metrohash64(
            <const uint8 *>PyBytes_AS_STRING(data),
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

    :param data: input data (either string or buffer type)
    :param seed: seed to random number generator (integer)
    :return: hash value (integer)
    :raises TypeError: if input data is not a string or a buffer
    :raises ValueError: if input buffer is not C-contiguous
    :raises OverflowError: if seed cannot be converted to unsigned int64
    """
    cdef Py_buffer buf
    cdef uint128 result
    cdef const char* encoding
    cdef Py_ssize_t encoding_size = 0

    if PyUnicode_Check(data):
        encoding = PyUnicode_AsUTF8AndSize(data, &encoding_size)
        result = c_metrohash128(<const uint8 *>encoding, encoding_size, seed)
    elif PyBytes_Check(data):
        result = c_metrohash128(
            <const uint8 *>PyBytes_AS_STRING(data),
            PyBytes_GET_SIZE(data), seed)
    elif PyObject_CheckBuffer(data):
        PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
        result = c_metrohash128(<const uint8 *>buf.buf, buf.len, seed)
        PyBuffer_Release(&buf)
    else:
        raise _type_error("data", ["basestring", "buffer"], data)
    return (long(result.first) << 64ULL) + long(result.second)


cdef class MetroHash64(object):
    """Incremental hasher interface for MetroHash-64.

    :param seed: seed to random number generator (integer)
    :raises TypeError: if seed is not an integer type
    :raises MemoryError: if a new method fails
    :raises OverflowError: if seed is out of bounds
    """

    cdef CCMetroHash64* _m

    def __cinit__(self, uint64 seed=0ULL) -> None:
        self._m = new CCMetroHash64(seed)
        if self._m is NULL:
            raise MemoryError()

    def __dealloc__(self) -> None:
        if not self._m is NULL:
            del self._m
            self._m = NULL

    def reset(self, uint64 seed=0ULL) -> None:
        """Reset state with a new seed.

        :param seed: new seed to reset state to (integer)
        :raises TypeError: if seed is not an integer type
        :raises OverflowError: if seed is out of bounds
        """
        self._m.Initialize(seed)

    def update(self, data) -> None:
        """Update digest with new data.

        :param data: input data (either string or buffer type)
        :raises TypeError: if input data is not a string or a buffer
        :raises ValueError: if input buffer is not C-contiguous
        """
        cdef Py_buffer buf
        cdef const char* encoding
        cdef Py_ssize_t encoding_size = 0

        if PyUnicode_Check(data):
            encoding = PyUnicode_AsUTF8AndSize(data, &encoding_size)
            self._m.Update(<const uint8 *>encoding, encoding_size)
        elif PyBytes_Check(data):
            self._m.Update(
                <const uint8 *>PyBytes_AS_STRING(data),
                PyBytes_GET_SIZE(data))
        elif PyObject_CheckBuffer(data):
            PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
            self._m.Update(<const uint8 *>buf.buf, buf.len)
            PyBuffer_Release(&buf)
        else:
            raise _type_error("data", ["basestring", "buffer"], data)

    cpdef bytes digest(self):
        """Obtain bytes digest.

        :return: eight bytes representing the 64-bit hash
        """
        cdef bytearray out = bytearray(8)
        self._m.Finalize(out)
        return bytes(out)

    def hexdigest(self) -> str:
        """Obtain a string digest in hexadecimal form.

        :return: hash string
        """
        return bytes2hex(self.digest())

    def intdigest(self) -> int:
        """Obtain a long integer representing hash value.

        :return: an integer representing 64-bit hash value
        """
        cdef uint8 buf[8]
        self._m.Finalize(buf)
        return c_bytes2int64(buf)


cdef class MetroHash128(object):
    """Incremental hasher interface for MetroHash-128.

    :param seed: seed to random number generator (integer)
    :raises TypeError: if seed is not an integer type
    :raises MemoryError: if a new method fails
    :raises OverflowError: if seed is out of bounds
    """

    cdef CCMetroHash128* _m

    def __cinit__(self, uint64 seed=0ULL) -> None:
        self._m = new CCMetroHash128(seed)
        if self._m is NULL:
            raise MemoryError()

    def __dealloc__(self) -> None:
        if not self._m is NULL:
            del self._m
            self._m = NULL

    def reset(self, uint64 seed=0ULL) -> None:
        """Reset state with a new seed.

        :param seed: new seed to reset state to (integer)
        :param TypeError: if seed is not an integer type
        :param OverflowError: if seed is out of bounds
        """
        self._m.Initialize(seed)

    def update(self, data) -> None:
        """Update digest with new data.

        :param data: input data (either string or buffer type)
        :raises TypeError: if input data is not a string or a buffer
        :raises ValueError: if input buffer is not C-contiguous
        """
        cdef Py_buffer buf
        cdef const char* encoding
        cdef Py_ssize_t encoding_size = 0

        if PyUnicode_Check(data):
            encoding = PyUnicode_AsUTF8AndSize(data, &encoding_size)
            self._m.Update(<const uint8 *>encoding, encoding_size)
        elif PyBytes_Check(data):
            self._m.Update(
                <const uint8 *>PyBytes_AS_STRING(data),
                PyBytes_GET_SIZE(data))
        elif PyObject_CheckBuffer(data):
            PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
            self._m.Update(<const uint8 *>buf.buf, buf.len)
            PyBuffer_Release(&buf)
        else:
            raise _type_error("data", ["basestring", "buffer"], data)

    cpdef bytes digest(self):
        """Obtain bytes digest.

        :return: sixteen bytes representing the 128-bit hash
        """
        cdef bytearray out = bytearray(16)
        self._m.Finalize(out)
        return bytes(out)

    def hexdigest(self) -> str:
        """Obtain a string digest in hexadecimal form.

        :return: hash string
        """
        return bytes2hex(self.digest())

    def intdigest(self) -> int:
        """Obtain integer digest.

        :return: a long integer representing 128-bit hash value
        """
        cdef uint8 buf[16]
        self._m.Finalize(buf)
        cdef uint128 result = c_bytes2int128(buf)
        return (long(result.first) << 64ULL) + long(result.second)
