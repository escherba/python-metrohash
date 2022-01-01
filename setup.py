#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
from os.path import join, dirname
from setuptools import setup
from setuptools.extension import Extension
from setuptools.dist import Distribution

try:
    from cpuinfo import get_cpu_info
    CPU_FLAGS = get_cpu_info()['flags']
except Exception as exc:
    CPU_FLAGS = {}

try:
    from Cython.Distutils import build_ext
    USE_CYTHON = True
except ImportError:
    USE_CYTHON = False


class BinaryDistribution(Distribution):
    """
    Subclass the setuptools Distribution to flip the purity flag to false.
    See https://lucumr.pocoo.org/2014/1/27/python-on-wheels/
    """
    def is_pure(self):
        """Returns purity flag"""
        return False


CXXFLAGS = []

print("building for platform: %s" % os.name)
print("available CPU flags: %s" % CPU_FLAGS)

if os.name == "nt":
    CXXFLAGS.extend(["/O2"])
else:
    CXXFLAGS.extend([
        "-O3",
        "-Wno-unused-value",
        "-Wno-unused-function",
    ])


if 'ssse3' in CPU_FLAGS:
    print("Compiling with SSSE3 enabled")
    CXXFLAGS.append('-mssse3')
else:
    print("compiling without SSE3 support")


if 'sse4_2' in CPU_FLAGS:
    print("Compiling with SSSE4.2 enabled")
    CXXFLAGS.append('-msse4.2')
else:
    print("compiling without SSE4.2 support")


INCLUDE_DIRS = ['src']
CXXHEADERS = [
    "src/metro.h",
    "src/metrohash.h",
    "src/metrohash128.h",
    "src/metrohash128crc.h",
    "src/metrohash64.h",
    "src/platform.h",
]
CXXSOURCES = [
    "src/metrohash64.cc",
    "src/metrohash128.cc",
]

EXT_MODULES = []

if USE_CYTHON:
    print("building extension using Cython")
    CMDCLASS = {'build_ext': build_ext}
    SRC_EXT = ".pyx"
else:
    print("building extension w/o Cython")
    CMDCLASS = {}
    SRC_EXT = ".cpp"


EXT_MODULES = [
    Extension(
        "metrohash",
        CXXSOURCES + ["src/metrohash" + SRC_EXT],
        depends=CXXHEADERS,
        language="c++",
        extra_compile_args=CXXFLAGS,
        include_dirs=INCLUDE_DIRS,
    ),
]

VERSION = '0.1.1.post2'
URL = "https://github.com/escherba/python-metrohash"


LONG_DESCRIPTION = """

"""


def get_long_description():
    fname = join(dirname(__file__), 'README.rst')
    try:
        with open(fname, 'rb') as fh:
            return fh.read().decode('utf-8')
    except Exception:
        return LONG_DESCRIPTION


setup(
    version=VERSION,
    description="Python bindings for MetroHash, a fast non-cryptographic hash algorithm",
    author="Eugene Scherba",
    author_email="escherba+metrohash@gmail.com",
    url=URL,
    download_url=URL + "/tarball/master/" + VERSION,
    name='metrohash',
    license='Apache License 2.0',
    zip_safe=False,
    cmdclass=CMDCLASS,
    ext_modules=EXT_MODULES,
    keywords=['hash', 'hashing', 'metrohash'],
    classifiers=[
        'Development Status :: 5 - Production/Stable',
        'Intended Audience :: Developers',
        'Intended Audience :: Science/Research',
        'License :: OSI Approved :: Apache Software License',
        'Operating System :: OS Independent',
        'Programming Language :: C++',
        'Programming Language :: Cython',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3.4',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
        'Programming Language :: Python :: 3.9',
        'Topic :: Scientific/Engineering :: Information Analysis',
        'Topic :: Software Development :: Libraries',
        'Topic :: Utilities'
    ],
    long_description=get_long_description(),
    long_description_content_type='text/x-rst',
    tests_require=['pytest'],
    distclass=BinaryDistribution,
)
