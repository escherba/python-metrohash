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


inline uint64_t bytes2int64(uint8_t * const array)
{
    // uint64_t is guaranteed to be 8 bytes long
    return (uint64_t)(
              static_cast<uint64_t>(array[0])
            | static_cast<uint64_t>(array[1]) << (8 * 1)
            | static_cast<uint64_t>(array[2]) << (8 * 2)
            | static_cast<uint64_t>(array[3]) << (8 * 3)
            | static_cast<uint64_t>(array[4]) << (8 * 4)
            | static_cast<uint64_t>(array[5]) << (8 * 5)
            | static_cast<uint64_t>(array[6]) << (8 * 6)
            | static_cast<uint64_t>(array[7]) << (8 * 7));
}


uint64_t metrohash64(const uint8_t * buffer, const uint64_t length, const uint64_t seed)
{
    uint8_t hash[8];
    MetroHash64::Hash(buffer, length, hash, seed);
    uint64_t result = bytes2int64(hash);
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
