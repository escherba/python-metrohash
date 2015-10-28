from setuptools import setup
from setuptools.extension import Extension
from setuptools.dist import Distribution
from pkg_resources import resource_string


try:
    from Cython.Distutils import build_ext
except ImportError:
    USE_CYTHON = False
else:
    USE_CYTHON = True


class BinaryDistribution(Distribution):
    """
    Subclass the setuptools Distribution to flip the purity flag to false.
    See http://lucumr.pocoo.org/2014/1/27/python-on-wheels/
    """
    def is_pure(self):
        # TODO: check if this is still necessary with Python v2.7
        return False


CXXFLAGS = u"""
-O3
-msse4.2
-Wno-unused-value
-Wno-unused-function
""".split()


INCLUDE_DIRS = ['include']
CXXHEADERS = [
    "include/metro.h",
    "include/metrohash.h",
    "include/metrohash128.h",
    "include/metrohash128crc.h",
    "include/metrohash64.h",
    "include/platform.h",
]
CXXSOURCES = [
    "src/metrohash64.cc",
    "src/metrohash128.cc",
]

CMDCLASS = {}
EXT_MODULES = []

if USE_CYTHON:
    EXT_MODULES.append(
        Extension(
            "metrohash",
            CXXSOURCES + ["src/metrohash.pyx"],
            depends=CXXHEADERS,
            language="c++",
            extra_compile_args=CXXFLAGS,
            include_dirs=INCLUDE_DIRS)
    )
    CMDCLASS['build_ext'] = build_ext
else:
    EXT_MODULES.append(
        Extension(
            "metrohash",
            CXXSOURCES + ["src/metrohash.cpp"],
            depends=CXXHEADERS,
            language="c++",
            extra_compile_args=CXXFLAGS,
            include_dirs=INCLUDE_DIRS)
    )

VERSION = '0.0.12'
URL = "https://github.com/escherba/python-metrohash"

setup(
    version=VERSION,
    description="Python bindings for MetroHash, a fast non-cryptographic hash algorithm",
    author="Eugene Scherba",
    author_email="escherba+metrohash@gmail.com",
    url=URL,
    download_url=URL + "/tarball/master/" + VERSION,
    name='metrohash',
    license='MIT',
    zip_safe=False,
    cmdclass=CMDCLASS,
    ext_modules=EXT_MODULES,
    keywords=['hash', 'hashing', 'metrohash', 'cityhash'],
    classifiers=[
        'Development Status :: 4 - Beta',
        'Intended Audience :: Developers',
        'Intended Audience :: Science/Research',
        'License :: OSI Approved :: MIT License',
        'Operating System :: OS Independent',
        'Programming Language :: C++',
        'Programming Language :: Cython',
        'Programming Language :: Python :: 2.7',
        'Topic :: Internet',
        'Topic :: Scientific/Engineering',
        'Topic :: Scientific/Engineering :: Information Analysis',
        'Topic :: Software Development',
        'Topic :: Software Development :: Libraries :: Python Modules',
        'Topic :: Utilities'
    ],
    long_description=resource_string(__name__, 'README.rst'),
    distclass=BinaryDistribution,
)
