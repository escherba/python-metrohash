/*
 * =====================================================================================
 *
 *       Filename:  metrohash64_test.cpp
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  10/12/2015 16:30:58
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Eugene Scherba (es), escherba@gmail.com
 *   Organization:  
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

#define TEST_STRING "abracadabra"

#define STRLEN(s) (sizeof(s)/sizeof(s[0]))


TEST_CASE( "basic test", "[basic]" ) {
    uint8_t * const hash = (uint8_t * const)calloc(9, sizeof(uint8_t));
    const uint8_t test_string[] = "abracadabra";
    REQUIRE(hash[0] == (uint8_t)'\0');
    REQUIRE(hash[8] == (uint8_t)'\0');
    MetroHash64::Hash((uint8_t * const)test_string, STRLEN(test_string), hash, 0);
    REQUIRE(hash[0] != (uint8_t)'\0');
    REQUIRE(hash[8] == (uint8_t)'\0');
}
