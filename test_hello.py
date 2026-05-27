import pytest

from hello import add, average, greet


def test_greet():
    assert greet("world") == "Hello, world"


def test_add():
    assert add(2, 3) == 5


def test_average():
    assert average([1, 2, 3, 4]) == 2.5


def test_average_empty():
    assert average([]) == 0
