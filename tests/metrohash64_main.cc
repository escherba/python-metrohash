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
 *         Author:  Eugene Scherba (es), escherba+metrohash@gmail.com
 *   Organization:  -
 *
 * =====================================================================================
 */

#include <iostream>
#include <fstream>
#include <sstream>
#include "metro.h"


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
