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

    def test_string_unicode_64(self):
        """Empty Python string has same hash value as empty Unicode string
        """
        self.assertEqual(metrohash64(""), metrohash64(u""))

    def test_string_unicode_128(self):
        """Empty Python string has same hash value as empty Unicode string
        """
        self.assertEqual(metrohash128(""), metrohash128(u""))

    def test_consistent_encoding_64(self):
        """ASCII-range Unicode strings have the same hash values as ASCII strings
        """
        text = u"abracadabra"
        self.assertEqual(metrohash64(text), metrohash64(text.encode("utf-8")))

    def test_consistent_encoding_128(self):
        """ASCII-range Unicode strings have the same hash values as ASCII strings
        """
        text = u"abracadabra"
        self.assertEqual(metrohash128(text), metrohash128(text.encode("utf-8")))

    def test_unicode_1_64(self):
        """Accepts Unicode input"""
        test_case = u"abc"
        self.assertTrue(isinstance(metrohash64(test_case), long))

    def test_unicode_1_128(self):
        """Accepts Unicode input"""
        test_case = u"abc"
        self.assertTrue(isinstance(metrohash128(test_case), long))

    def test_unicode_2_64(self):
        """Accepts Unicode input outside of ASCII range"""
        test_case = u'\u2661'
        self.assertTrue(isinstance(metrohash64(test_case), long))

    def test_unicode_2_128(self):
        """Accepts Unicode input outside of ASCII range"""
        test_case = u'\u2661'
        self.assertTrue(isinstance(metrohash128(test_case), long))


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
            incremental = m1.intdigest()
            m2 = hasher()
            m2.update(data)
            whole = m2.intdigest()
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
            incremental = m1.intdigest()
            m2 = hasher()
            m2.update(data)
            whole = m2.intdigest()
            msg = "\ndata: %s\nwhole: %s\nincremental: %s\n" % (pieces, whole, incremental)
            self.assertEqual(whole, incremental, msg)
