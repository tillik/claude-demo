def greet(name):
    return "Hello, " + name


def add(a, b):
    return a + b


def average(numbers):
    total = 0
    for n in numbers:
        total += n
    if not numbers:
        return 0
    return total / len(numbers)


if __name__ == "__main__":
    print(greet("world"))
    print(add(2, 3))
    print(average([1, 2, 3, 4]))
