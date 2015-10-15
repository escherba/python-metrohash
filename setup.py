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


setup(
    version="0.0.1",
    description="Python bindings for MetroHash",
    author="Eugene Scherba",
    author_email="escherba+metrohash@gmail.com",
    url="https://github.com/escherba/metrohash",
    name='metrohash',
    license='MIT',
    cmdclass={'build_ext': build_ext_subclass},
    ext_modules=[Extension("metrohash", ["src/metrohash64.cpp",
                                         "src/metrohash128.cpp",
                                         "src/metrohash.pyx"],
                           language="c++",
                           extra_compile_args=['-O3', '-msse4.2'],
                           include_dirs=['include'])],
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
