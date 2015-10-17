from setuptools import setup, Extension
from pkg_resources import resource_string
from Cython.Distutils import build_ext


class build_ext_subclass(build_ext):
    """
    This class is an ugly hack to a problem that arises when one must force
    a compiler to use specific flags by adding to the environment somethiing
    like the following:

        CXX="clang --some_flagA --some_flagB -I/usr/bin/include/mylibC"

    (as opposed to setting CXXFLAGS). Distutils in that case will complain
    that it cannot run the entire command as given because it is not
    found as an executable (specific error message is: "unable to execute...
    ... no such file or directory").

    This subclass of ``build_ext`` will extract the compiler name from the
    command line and insert any remaining arguments right after it.
    """
    def build_extensions(self):
        ccm = self.compiler.compiler
        if ' ' in ccm[0]:
            self.compiler.compiler = ccm[0].split(' ') + ccm[1:]
        cxx = self.compiler.compiler_cxx
        if ' ' in cxx[0]:
            self.compiler.compiler_cxx = cxx[0].split(' ') + cxx[1:]
        build_ext.build_extensions(self)


CXXFLAGS = u"""
-O3
-msse4.2
-Wno-unused-value
-Wno-unused-function
""".split()

VERSION = '0.0.5'
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
    cmdclass={'build_ext': build_ext_subclass},
    zip_safe=False,
    ext_modules=[Extension("metrohash",
                           [
                               "src/metrohash64.cc",
                               "src/metrohash128.cc",
                               "src/metrohash.pyx"
                           ],
                           depends=[
                               "include/metro.h",
                               "include/metrohash.h",
                               "include/metrohash128.h",
                               "include/metrohash128crc.h",
                               "include/metrohash64.h",
                               "include/platform.h"
                           ],
                           language="c++",
                           extra_compile_args=CXXFLAGS,
                           include_dirs=['include'])],
    keywords=['hash', 'hashing'],
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
)
