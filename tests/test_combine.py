import unittest
from functools import reduce
from metrohash import metrohash64, PHashCombiner, hash_combine_1, \
    hash_combine_2


class TestCombiners(unittest.TestCase):

    def test_hash_combiner_0(self):
        """PHashCombiner should work on long inputs"""
        vec = [metrohash64(str(x)) for x in range(8)]
        comb = PHashCombiner(8)
        self.assertEqual(16761784773908155715L, comb.combine(vec))

    def test_hash_combiner_1(self):
        """PHashCombiner should work on long inputs"""
        vec = [metrohash64(str(x)) for x in range(100)]
        comb = PHashCombiner(18)
        self.assertNotEqual(comb.combine(vec[:17]), comb.combine(vec[:18]))
        self.assertEqual(comb.combine(vec[:18]), comb.combine(vec[:19]))

    def test_hash_combiner_2(self):
        """PHashCombiner should return 0 on empty inputs"""
        comb = PHashCombiner(8)
        self.assertEqual(0L, comb.combine([]))

    def test_hash_combine_1(self):
        """hash_combine_1 should work"""
        vec = [metrohash64(str(x)) for x in range(8)]
        result = reduce(hash_combine_1, vec, 1337L)
        for val in vec:
            self.assertNotEqual(result, val)
        self.assertEqual(4912212594039284774L, result)

    def test_hash_combine_2(self):
        """hash_combine_2 should work"""
        vec = [metrohash64(str(x)) for x in range(8)]
        result = reduce(hash_combine_2, vec, 1337L)
        for val in vec:
            self.assertNotEqual(result, val)
        self.assertEqual(742260322578448263L, result)
