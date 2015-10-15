#cython: infer_types=True

"""
A Python wrapper around MetroHash, a fast non-cryptographic hashing algorithm
"""

__author__      = "Eugene Scherba"
__email__       = "escherba+metrohash@gmail.com"
__all__         = ["metrohash64",
                   "metrohash128",
                   "hash_combine_1",
                   "hash_combine_2",
                   "PHashCombiner",
                   #"mh64",
                   #"mh128",
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
    cdef uint64 c_metrohash64 "metrohash64" (const uint8 *buf, uint64 len, uint64 seed)
    cdef uint64 c_hash_combine_1 "hash_combine_1" (uint64 seed, uint64 v)
    cdef uint64 c_hash_combine_2 "hash_combine_2" (uint64 seed, uint64 v)
    cdef uint128[uint64,uint64] c_metrohash128 "metrohash128" (const uint8 *buf, uint64 len, uint64 seed)


cpdef metrohash64(bytes buf, uint64 seed=0):
    """Hash function for a byte array
    """
    return c_metrohash64(buf, len(buf), seed)


cpdef metrohash128(bytes buf, uint64 seed=0):
    """Hash function for a byte array
    """
    cdef pair[uint64, uint64] result = c_metrohash128(buf, len(buf), seed)
    return (result.first, result.second)


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

    cpdef uint64 combine(self, hashes):
        """Combine a list of integer hashes
        """
        return sum([h * c for h, c in izip(hashes, self._coeffs)]) % self._mod


#cdef class mh64:
#    cdef uint64 __value
#    cdef public bytes name
#    def __cinit__(self, bytes value=str("")):
#        self.name = str("CityHash64")
#        self.update(value)
#    cpdef update(self, bytes value):
#        if self.__value:
#            self.__value = c_CityHash64WithSeed(value, len(value), self.__value)
#        else:
#            self.__value = c_CityHash64(value, len(value))
#    cpdef digest(self):
#        return self.__value
#
#cdef class mh128:
#    cdef tuple __value
#    cdef public bytes name
#    def __cinit__(self, bytes value=str("")):
#        self.name = str("CityHash128")
#        self.update(value)
#    cpdef update(self, bytes value):
#        if self.__value:
#            self.__value = CityHash128WithSeed(value, self.__value)
#        else:
#            self.__value = CityHash128(value)
#    cpdef digest(self):
#        return self.__value
