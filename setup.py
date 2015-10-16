from setuptools import setup
from distutils.extension import Extension
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

VERSION = '0.0.3'
URL = "https://github.com/escherba/python-metrohash"

setup(
    version=VERSION,
    description="Python bindings for MetroHash",
    author="Eugene Scherba",
    author_email="escherba+metrohash@gmail.com",
    url=URL,
    download_url=URL + "/tarball/master/" + VERSION,
    name='metrohash',
    license='MIT',
    cmdclass={'build_ext': build_ext_subclass},
    ext_modules=[Extension("metrohash", ["src/metrohash64.cc",
                                         "src/metrohash128.cc",
                                         "src/metrohash.pyx"],
                           language="c++",
                           extra_compile_args=CXXFLAGS,
                           include_dirs=['include'])],
    keywords=['hashing'],
    classifiers=[
        'Development Status :: 3 - Alpha',
        'Operating System :: OS Independent',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: MIT License',
        'Topic :: Software Development :: Libraries :: Python Modules',
        'Programming Language :: Python :: 2.7',
    ],
    long_description=resource_string(__name__, 'README.rst'),
)
