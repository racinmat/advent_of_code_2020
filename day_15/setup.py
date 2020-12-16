from setuptools import setup
from Cython.Build import cythonize

setup(
    ext_modules=cythonize("game.pyx", annotate=True, language_level="3", language="c++"),
)
