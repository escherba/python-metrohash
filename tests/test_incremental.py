import unittest
import random
import string
from metrohash import CMetroHash64, CMetroHash128, metrohash64, metrohash128


def random_string(n, alphabet=string.ascii_lowercase):
    return ''.join(random.choice(alphabet) for _ in range(n))


def random_splits(string, n, nsplits=2):
    splits = sorted([random.randint(0, n) for _ in range(nsplits - 1)])
    splits = [0] + splits + [n]
    for a, b in zip(splits, splits[1:]):
        yield string[a:b]


class TestStandalone(unittest.TestCase):

    def test_unicode_64_1(self):
        """Must accept Unicode input"""
        test_case = u"abc"
        self.assertEqual(17099979927131455419L,
                         metrohash64(test_case))

    def test_unicode_64_2(self):
        """Must accept Unicode input"""
        test_case = u'\u2661'
        self.assertEqual(89830315997599275L,
                         metrohash64(test_case))

    def test_unicode_128_1(self):
        """Must accept Unicode input"""
        test_case = u"abc"
        self.assertEqual(182995299641628952910564950850867298725L,
                         metrohash128(test_case))

    def test_unicode_128_2(self):
        """Must accept Unicode input"""
        test_case = u'\u2661'
        self.assertEqual(71044331826727115060124269853582874788L,
                         metrohash128(test_case))


class TestCombiners(unittest.TestCase):

    def test_compose_64(self):
        """Test various ways to split a string
        """
        nchars = 1000
        split_range = (2, 10)
        num_tests = 100
        hasher = CMetroHash64
        alphabet = string.ascii_uppercase + string.ascii_lowercase + string.digits

        for _ in xrange(num_tests):
            data = random_string(nchars, alphabet=alphabet)
            m1 = hasher()
            pieces = list(random_splits(data, nchars, random.randint(*split_range)))
            for piece in pieces:
                m1.update(piece)
            incremental = m1.finalize()
            m2 = hasher()
            m2.update(data)
            whole = m2.finalize()
            msg = "\ndata: %s\nwhole: %s\nincremental: %s\n" % (pieces, whole, incremental)
            self.assertEqual(whole, incremental, msg)

    def test_compose_128(self):
        """Test various ways to split a string
        """
        nchars = 20
        split_range = (2, 4)
        num_tests = 10
        hasher = CMetroHash128
        alphabet = string.ascii_lowercase

        for _ in xrange(num_tests):
            data = random_string(nchars, alphabet=alphabet)
            m1 = hasher()
            pieces = list(random_splits(data, nchars, random.randint(*split_range)))
            for piece in pieces:
                m1.update(piece)
            incremental = m1.finalize()
            m2 = hasher()
            m2.update(data)
            whole = m2.finalize()
            msg = "\ndata: %s\nwhole: %s\nincremental: %s\n" % (pieces, whole, incremental)
            self.assertEqual(whole, incremental, msg)
