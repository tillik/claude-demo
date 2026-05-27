import pytest

from hello import add, average, greet, shout


def test_greet():
    assert greet("world") == "Hello, world"


def test_add():
    assert add(2, 3) == 5


def test_average():
    assert average([1, 2, 3, 4]) == 2.5


def test_average_empty():
    assert average([]) == 0


def test_shout():
    assert shout("world") == "HELLO, WORLD"


def test_shout_name():
    assert shout("Alice") == "HELLO, ALICE"
