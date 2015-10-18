#cython: infer_types=True

"""
A Python wrapper for MetroHash, a fast non-cryptographic hashing algorithm
"""

__author__  = "Eugene Scherba"
__email__   = "escherba+metrohash@gmail.com"
__version__ = "0.0.7"
__all__     = [
    "metrohash64", "metrohash128",
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
    cdef uint64 c_metrohash64 "metrohash64" (const uint8* buff, uint64 len, uint64 seed)
    cdef uint64 c_bytes2int64 "bytes2int64" (uint8* const array)
    cdef uint128[uint64,uint64] c_bytes2int128 "bytes2int128" (uint8* const array)
    cdef uint128[uint64,uint64] c_metrohash128 "metrohash128" (const uint8* buff, uint64 len, uint64 seed)
    cdef cppclass MetroHash64:
        MetroHash64(const uint64 seed)
        void Initialize(const uint64 seed)
        void Update(const uint8* buff, const uint64 length)
        void Finalize(uint8* const result)
    cdef cppclass MetroHash128:
        MetroHash128(const uint64 seed)
        void Initialize(const uint64 seed)
        void Update(const uint8* buff, const uint64 length)
        void Finalize(uint8* const result)


cdef const uint8* _chars(basestring s):
    if isinstance(s, unicode):
        s = s.encode('utf8')
    return s


cpdef metrohash64(basestring data, uint64 seed=0):
    """Hash function for a byte array
    """
    cdef const uint8* array = _chars(data)
    return c_metrohash64(array, len(array), seed)


cpdef metrohash128(basestring data, uint64 seed=0):
    """Hash function for a byte array
    """
    cdef const uint8* array = _chars(data)
    cdef pair[uint64, uint64] result = c_metrohash128(array, len(array), seed)
    return 0x10000000000000000L * long(result.first) + long(result.second)


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

    def update(self, basestring data):
        cdef const uint8* array = _chars(data)
        self._m.Update(array, len(array))

    def intdigest(self):
        cdef uint8 buff[8]
        self._m.Finalize(buff)
        return c_bytes2int64(buff)


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

    def update(self, basestring data):
        cdef const uint8* array = _chars(data)
        self._m.Update(array, len(array))

    def intdigest(self):
        cdef uint8 buff[16]
        self._m.Finalize(buff)
        cdef pair[uint64, uint64] result = c_bytes2int128(buff)
        return 0x10000000000000000L * long(result.first) + long(result.second)
