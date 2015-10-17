import unittest
from functools import reduce
from metrohash import metrohash64, PHashCombiner, hash_combine_1, \
    hash_combine_2


class TestCombiners(unittest.TestCase):

    def test_hash_combiner_0(self):
        """PHashCombiner should work on long inputs"""
        vec = [metrohash64(str(x)) for x in range(8)]
        comb = PHashCombiner(8)
        self.assertEqual(16761784768726726692L, comb.combine(vec))

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

    def _check_combiner(self, func):
        VEC_SIZE = 8
        vec = [metrohash64(str(x)) for x in range(VEC_SIZE)]
        result1 = reduce(func, vec, 0L)
        for val in vec:
            self.assertNotEqual(result1, val)
        vec[VEC_SIZE // 2] = metrohash64("test")
        result2 = reduce(func, vec, 0L)
        for val in vec:
            self.assertNotEqual(result2, val)
        self.assertNotEqual(result1, result2)

    def test_hash_combine_1(self):
        """hash_combine_1 should work"""
        self._check_combiner(hash_combine_1)

    def test_hash_combine_2(self):
        """hash_combine_2 should work"""
        self._check_combiner(hash_combine_2)
