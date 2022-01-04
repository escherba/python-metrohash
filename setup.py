#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import struct
from os.path import join, dirname

from setuptools import setup
from setuptools.dist import Distribution
from setuptools.extension import Extension

try:
    from cpuinfo import get_cpu_info

    CPU_FLAGS = get_cpu_info()["flags"]
except Exception as exc:
    print("exception loading cpuinfo", exc)
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


def get_system_bits():
    """Return 32 for 32-bit systems and 64 for 64-bit"""
    return struct.calcsize("P") * 8


SYSTEM = os.name
BITS = get_system_bits()
HAVE_SSE42 = "sse4_2" in CPU_FLAGS
HAVE_AES = "aes" in CPU_FLAGS

CXXFLAGS = []

print("system: %s-%d" % (SYSTEM, BITS))
print("available CPU flags:", CPU_FLAGS)
print("environment:", ", ".join(["%s=%s" % (k, v) for k, v in os.environ.items()]))

if SYSTEM == "nt":
    CXXFLAGS.extend(["/O2"])
else:
    CXXFLAGS.extend(
        [
            "-O3",
            "-Wno-unused-value",
            "-Wno-unused-function",
        ]
    )

# The "cibuildwheel" tool sets the variable below to
# something like x86_64, aarch64, i686, and so on.
TARGET_ARCH = os.environ.get("AUDITWHEEL_ARCH")

if HAVE_SSE42 and (TARGET_ARCH in [None, "x86_64"]) and (BITS == 64):
    print("enabling SSE4.2 on compile")
    if SYSTEM == "nt":
        CXXFLAGS.append("/D__SSE4_2__")
    else:
        CXXFLAGS.append("-msse4.2")


if HAVE_AES and (TARGET_ARCH in [None, "x86_64"]) and (BITS == 64):
    print("enabling AES on compile")
    if SYSTEM == "nt":
        CXXFLAGS.append("/D__AES__")
    else:
        CXXFLAGS.append("-maes")

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


if USE_CYTHON:
    print("building extension using Cython")
    CMDCLASS = {"build_ext": build_ext}
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
        include_dirs=["src"],
    ),
]

VERSION = "0.2.1"
URL = "https://github.com/escherba/python-metrohash"


def get_long_description(relpath, encoding="utf-8"):
    _long_desc = """

    """
    fname = join(dirname(__file__), relpath)
    try:
        with open(fname, "rb") as fh:
            return fh.read().decode(encoding)
    except Exception:
        return _long_desc


setup(
    version=VERSION,
    description="Python bindings for MetroHash, a fast non-cryptographic hash algorithm",
    author="Eugene Scherba",
    author_email="escherba+metrohash@gmail.com",
    url=URL,
    download_url=URL + "/tarball/master/" + VERSION,
    name="metrohash",
    license="Apache License 2.0",
    zip_safe=False,
    cmdclass=CMDCLASS,
    ext_modules=EXT_MODULES,
    package_dir={"": "src"},
    keywords=["hash", "hashing", "metrohash", "cython"],
    classifiers=[
        "Development Status :: 5 - Production/Stable",
        "Intended Audience :: Developers",
        "Intended Audience :: Science/Research",
        "License :: OSI Approved :: Apache Software License",
        "Operating System :: OS Independent",
        "Programming Language :: C++",
        "Programming Language :: Cython",
        "Programming Language :: Python :: 3.6",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Topic :: Scientific/Engineering :: Information Analysis",
        "Topic :: Software Development :: Libraries",
        "Topic :: System :: Distributed Computing",
    ],
    long_description=get_long_description("README.md"),
    long_description_content_type="text/markdown",
    tests_require=["pytest"],
    distclass=BinaryDistribution,
)
