/*
 * =====================================================================================
 *
 *       Filename:  metro.h
 *
 *    Description:  Wrapper around metrohash.h
 *
 *        Version:  1.0
 *        Created:  10/14/2015 18:24:45
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Eugene Scherba (es), escherba+metrohash@gmail.com
 *   Organization:  -
 *
 * =====================================================================================
 */

#include <stdlib.h>  // for size_t.
#include <stdint.h>
#include <utility>


#include "metrohash.h"

typedef uint8_t uint8;
typedef uint32_t uint32;
typedef uint64_t uint64;
typedef std::pair<uint64, uint64> uint128;


inline uint64 Uint128Low64(const uint128& x)
{
    return x.first;
}


inline uint64 Uint128High64(const uint128& x)
{
    return x.second;
}


inline uint64 bytes2int64(uint8_t * const array)
{
    // uint64 is guaranteed to be 8 bytes long
    return (uint64)(
              static_cast<uint64>(array[0])
            | static_cast<uint64>(array[1]) << (8 * 1)
            | static_cast<uint64>(array[2]) << (8 * 2)
            | static_cast<uint64>(array[3]) << (8 * 3)
            | static_cast<uint64>(array[4]) << (8 * 4)
            | static_cast<uint64>(array[5]) << (8 * 5)
            | static_cast<uint64>(array[6]) << (8 * 6)
            | static_cast<uint64>(array[7]) << (8 * 7));
}


inline uint128 bytes2int128(uint8_t * const array)
{
    // uint64 is guaranteed to be 8 bytes long
    uint64 a = (uint64)(
              static_cast<uint64>(array[0])
            | static_cast<uint64>(array[1]) << (8 * 1)
            | static_cast<uint64>(array[2]) << (8 * 2)
            | static_cast<uint64>(array[3]) << (8 * 3)
            | static_cast<uint64>(array[4]) << (8 * 4)
            | static_cast<uint64>(array[5]) << (8 * 5)
            | static_cast<uint64>(array[6]) << (8 * 6)
            | static_cast<uint64>(array[7]) << (8 * 7));

    uint64 b = (uint64)(
              static_cast<uint64>(array[8])
            | static_cast<uint64>(array[9])  << (8 * 1)
            | static_cast<uint64>(array[10]) << (8 * 2)
            | static_cast<uint64>(array[11]) << (8 * 3)
            | static_cast<uint64>(array[12]) << (8 * 4)
            | static_cast<uint64>(array[13]) << (8 * 5)
            | static_cast<uint64>(array[14]) << (8 * 6)
            | static_cast<uint64>(array[15]) << (8 * 7));

    return uint128(a, b);
}


inline uint64 metrohash64(const uint8_t *buffer, const uint64 length, const uint64 seed)
{
    uint8_t hash[8];
    MetroHash64::Hash(buffer, length, hash, seed);
    return bytes2int64(hash);
}


inline uint128 metrohash128(const uint8_t *buffer, const uint64 length, const uint64 seed)
{
    uint8_t hash[16];
    MetroHash128::Hash(buffer, length, hash, seed);
    return bytes2int128(hash);
}
