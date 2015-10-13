/*
 * =====================================================================================
 *
 *       Filename:  run_levc.cpp
 *
 *    Description:  Compute levenshtein distance (main)
 *
 *        Version:  1.0
 *        Created:  09/07/2015 21:21:41
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Eugene Scherba (es), escherba@gmail.com
 *   Organization:  -
 *
 * =====================================================================================
 */

#include <iostream>
#include <fstream>
#include <sstream>
#include "metrohash64.h"

#define STRLEN(s) (sizeof(s)/sizeof(s[0]))
#define HASH64_SZ 8


uint64_t bytes2int64(uint8_t * const array)
{
    // uint64_t is guaranteed to be 8 bytes long
    return (uint64_t)(
              static_cast<uint64_t>(array[0])
            | static_cast<uint64_t>(array[1]) << 8
            | static_cast<uint64_t>(array[2]) << 16
            | static_cast<uint64_t>(array[3]) << 24
            | static_cast<uint64_t>(array[4]) << 32
            | static_cast<uint64_t>(array[5]) << 40
            | static_cast<uint64_t>(array[6]) << 48
            | static_cast<uint64_t>(array[7]) << 56);
}


uint64_t metrohash64(const uint8_t * buffer, const uint64_t length, const uint64_t seed)
{
    uint8_t * const hash = (uint8_t * const)calloc(HASH64_SZ + 1, sizeof(uint8_t));
    MetroHash64::Hash((uint8_t * const)buffer, length, hash, seed);
    uint64_t result = bytes2int64(hash);
    free(hash);
    return result;
}


int main(int argc, char** argv) {
    std::string line;
    if (argc <= 1) {
        return EXIT_FAILURE;
    }
    std::ifstream infile(argv[1]);
    while (std::getline(infile, line))
    {
        uint64_t result = metrohash64((uint8_t*)line.c_str(), line.length(), 0);
        std::cout << result << "\t" << line << std::endl;
    }
    return EXIT_SUCCESS;
}
