#cython: infer_types=True

"""
A Python wrapper for MetroHash, a fast non-cryptographic hashing algorithm
"""

__author__  = "Eugene Scherba"
__email__   = "escherba+metrohash@gmail.com"
__version__ = "0.0.2"
__all__     = [
    "metrohash64", "metrohash128",
    "CMetroHash64", "CMetroHash128",
    "hash_combine_1", "hash_combine_2",
    "PHashCombiner",
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
    cdef uint64 c_hash_combine_1 "hash_combine_1" (uint64 seed, uint64 v)
    cdef uint64 c_hash_combine_2 "hash_combine_2" (uint64 seed, uint64 v)
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


cdef uint8* _chars(basestring s):
    if isinstance(s, unicode):
        s = s.encode('utf8')
    return s


cpdef metrohash64(basestring data, uint64 seed=0):
    """Hash function for a byte array
    """
    array = _chars(data)
    return c_metrohash64(array, len(array), seed)


cpdef metrohash128(basestring data, uint64 seed=0):
    """Hash function for a byte array
    """
    array = _chars(data)
    cdef pair[uint64, uint64] result = c_metrohash128(array, len(array), seed)
    return 0x10000000000000000 * int(result.first) + int(result.second)


cpdef hash_combine_1(uint64 seed, uint64 v):
    """Hash two 64-bit integers together

    Uses a Murmur-inspired hash function
    """
    return c_hash_combine_1(seed, v)


cpdef hash_combine_2(uint64 seed, uint64 v):
    """Hash two 64-bit integers together

    Uses boost::hash_combine algorithm
    """
    return c_hash_combine_2(seed, v)


from itertools import izip

cdef class PHashCombiner(object):
    """Use polynomial hashing to reduce a vector of hashes

    The result is bounded to uint64 maximum value by default although
    this can be overriden by changing `mod` initialization parameter
    """

    cdef list _coeffs
    cdef uint64 _mod

    def __init__(self, uint64 size, uint64 prime=31ULL, uint64 mod=0xFFFFFFFFFFFFFFFFULL):
        self._coeffs = [prime ** i for i in xrange(size)]
        self._mod = mod

    def combine(self, hashes):
        """Combine a list of integer hashes
        """
        return sum(h * c for h, c in izip(hashes, self._coeffs)) % self._mod


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
        array = _chars(data)
        self._m.Update(array, len(array))

    def finalize(self):
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
        array = _chars(data)
        self._m.Update(array, len(array))

    def finalize(self):
        cdef uint8 buff[16]
        self._m.Finalize(buff)
        cdef pair[uint64, uint64] result = c_bytes2int128(buff)
        return (result.first, result.second)
