import unittest
from metrohash import metrohash64, PHashCombiner


class TestUtils(unittest.TestCase):
    def test_hash_combine_1(self):
        """PHashCombiner should work on long inputs"""
        vec = [metrohash64(str(x)) for x in range(100)]
        comb = PHashCombiner(18)
        self.assertNotEqual(comb.combine(vec[:17]), comb.combine(vec[:18]))
        self.assertEqual(comb.combine(vec[:18]), comb.combine(vec[:19]))

    def test_hash_combine_2(self):
        """PHashCombiner should return 0 on empty inputs"""
        comb = PHashCombiner(8)
        self.assertEqual(0L, comb.combine([]))
