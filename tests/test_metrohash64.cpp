/*
 * =====================================================================================
 *
 *       Filename:  metrohash64_test.cpp
 *
 *    Description:  Some basic tests for 64-based MetroHash
 *
 *        Version:  1.0
 *        Created:  10/12/2015 16:30:58
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Eugene Scherba (es)
 *   Organization:  -
 *
 * =====================================================================================
 */
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <numeric>

#define CATCH_CONFIG_MAIN  // This tells Catch to provide a main() - only do this in one cpp file
#include "catch.hpp"
#include "metrohash64.h"

#define STRLEN(s) (sizeof(s)/sizeof(s[0]))
#define HASH64_SZ 8


TEST_CASE( "basic test", "[basic]" ) {
    uint8_t * const hash = (uint8_t * const)calloc(HASH64_SZ + 1, sizeof(uint8_t));
    const uint8_t test_string[] = "abracadabra";
    REQUIRE(hash[0] == (uint8_t)'\0');
    REQUIRE(hash[HASH64_SZ] == (uint8_t)'\0');
    MetroHash64::Hash((uint8_t * const)test_string, STRLEN(test_string), hash, 0);
    REQUIRE(hash[0] != (uint8_t)'\0');
    REQUIRE(hash[HASH64_SZ] == (uint8_t)'\0');
}

TEST_CASE( "test different seeds", "[diff_seeds]" ) {
    uint8_t * const hash1 = (uint8_t * const)calloc(HASH64_SZ + 1, sizeof(uint8_t));
    uint8_t * const hash2 = (uint8_t * const)calloc(HASH64_SZ + 1, sizeof(uint8_t));
    const uint8_t test_string[] = "abracadabra";
    MetroHash64::Hash(test_string, STRLEN(test_string), hash1, 0);
    MetroHash64::Hash(test_string, STRLEN(test_string), hash2, 1);
    REQUIRE(memcmp(hash1, hash2, HASH64_SZ) != 0);
}

TEST_CASE( "test different inputs", "[diff_inputs]" ) {
    uint8_t * const hash1 = (uint8_t * const)calloc(HASH64_SZ + 1, sizeof(uint8_t));
    uint8_t * const hash2 = (uint8_t * const)calloc(HASH64_SZ + 1, sizeof(uint8_t));
    const uint8_t test_string1[] = "abracadabr";
    const uint8_t test_string2[] = "abracaaabra";
    MetroHash64::Hash(test_string1, STRLEN(test_string1), hash1, 0);
    MetroHash64::Hash(test_string2, STRLEN(test_string2), hash2, 0);
    REQUIRE(memcmp(hash1, hash2, HASH64_SZ) != 0);
}
