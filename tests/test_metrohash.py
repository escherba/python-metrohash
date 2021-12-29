"""
Python-based tests for metrohash extension
"""
import unittest
import random
import string
import sys

from metrohash import (
    MetroHash64,
    MetroHash128,
    metrohash64,
    metrohash128
)


EMPTY_STRING = ""
EMPTY_UNICODE = u""  # pylint: disable=redundant-u-string-prefix


if sys.version_info[0] >= 3:
    long = int


def random_string(n, alphabet=string.ascii_lowercase):
    """generate a random string"""
    return ''.join(random.choice(alphabet) for _ in range(n))


def random_splits(s, n, nsplits=2):
    """split string in random places"""
    splits = sorted([random.randint(0, n) for _ in range(nsplits - 1)])
    splits = [0] + splits + [n]
    for begin, end in zip(splits, splits[1:]):
        yield s[begin:end]


class TestStandalone(unittest.TestCase):

    """test single-line methods"""

    def test_string_unicode_64(self):
        """Empty Python string has same hash value as empty Unicode string
        """
        self.assertEqual(metrohash64(EMPTY_STRING), metrohash64(EMPTY_UNICODE))

    def test_string_unicode_128(self):
        """Empty Python string has same hash value as empty Unicode string
        """
        self.assertEqual(metrohash128(EMPTY_STRING), metrohash128(EMPTY_UNICODE))

    def test_consistent_encoding_64(self):
        """ASCII-range Unicode strings have the same hash values as ASCII strings
        """
        text = u"abracadabra"  # pylint: disable=redundant-u-string-prefix
        self.assertEqual(metrohash64(text), metrohash64(text.encode("utf-8")))

    def test_consistent_encoding_128(self):
        """ASCII-range Unicode strings have the same hash values as ASCII strings
        """
        text = u"abracadabra"  # pylint: disable=redundant-u-string-prefix
        self.assertEqual(metrohash128(text), metrohash128(text.encode("utf-8")))

    def test_unicode_1_64(self):
        """Accepts Unicode input"""
        test_case = u"abc"  # pylint: disable=redundant-u-string-prefix
        self.assertTrue(isinstance(metrohash64(test_case), long))

    def test_unicode_1_128(self):
        """Accepts Unicode input"""
        test_case = u"abc"  # pylint: disable=redundant-u-string-prefix
        self.assertTrue(isinstance(metrohash128(test_case), long))

    def test_unicode_2_64(self):
        """Accepts Unicode input outside of ASCII range"""
        test_case = u'\u2661'  # pylint: disable=redundant-u-string-prefix
        self.assertTrue(isinstance(metrohash64(test_case), long))

    def test_unicode_2_128(self):
        """Accepts Unicode input outside of ASCII range"""
        test_case = u'\u2661'  # pylint: disable=redundant-u-string-prefix
        self.assertTrue(isinstance(metrohash128(test_case), long))

    def test_refcounts(self):
        """Doesn't leak references to its argument"""
        funcs = [metrohash64, metrohash128]
        args = ['abc', b'abc', bytearray(b'def'), memoryview(b'ghi')]
        for func in funcs:
            for arg in args:
                old_refcount = sys.getrefcount(arg)
                func(arg)
                self.assertEqual(sys.getrefcount(arg), old_refcount)

    def test_func_raises_type_error(self):
        """Check that functions raise type error"""
        funcs = [metrohash64, metrohash128]
        for func in funcs:
            with self.assertRaises(TypeError):
                func([])

    def test_obj_raises_type_error(self):
        """Check that hasher objects raise type error"""
        hasher_classes = [MetroHash64, MetroHash128]
        for hasher_class in hasher_classes:
            hasher = hasher_class()
            with self.assertRaises(TypeError):
                hasher.update([])


class TestCombiners(unittest.TestCase):

    """test combiners"""

    def test_compose_64(self):
        """Test various ways to split a string
        """
        nchars = 1000
        split_range = (2, 10)
        num_tests = 100
        hasher = MetroHash64
        alphabet = string.ascii_uppercase + string.ascii_lowercase + string.digits

        for _ in range(num_tests):
            data = random_string(nchars, alphabet=alphabet)
            hasher1 = hasher()
            pieces = list(random_splits(data, nchars, random.randint(*split_range)))
            for piece in pieces:
                hasher1.update(piece)
            incremental = hasher1.intdigest()
            hasher2 = hasher()
            hasher2.update(data)
            whole = hasher2.intdigest()
            msg = "\ndata: %s\nwhole: %s\nincremental: %s\n" % (pieces, whole, incremental)
            self.assertEqual(whole, incremental, msg)

    def test_compose_128(self):
        """Test various ways to split a string
        """
        nchars = 20
        split_range = (2, 4)
        num_tests = 10
        hasher = MetroHash128
        alphabet = string.ascii_lowercase

        for _ in range(num_tests):
            data = random_string(nchars, alphabet=alphabet)
            hasher1 = hasher()
            pieces = list(random_splits(data, nchars, random.randint(*split_range)))
            for piece in pieces:
                hasher1.update(piece)
            incremental = hasher1.intdigest()
            hasher2 = hasher()
            hasher2.update(data)
            whole = hasher2.intdigest()
            msg = "\ndata: %s\nwhole: %s\nincremental: %s\n" % (pieces, whole, incremental)
            self.assertEqual(whole, incremental, msg)
