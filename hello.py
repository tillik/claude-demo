def greet(name):
    return "Hello, " + name


def add(a, b):
    return a + b


def average(numbers):
    if not numbers:
        return 0
    total = 0
    for n in numbers:
        total += n
    return total / len(numbers)


if __name__ == "__main__":
    print(greet("world"))
    print(add(2, 3))
    print(average([1, 2, 3, 4]))
