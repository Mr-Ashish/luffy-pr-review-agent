"""Tiny demo module so Luffy has something to review in e2e."""

def greet(name: str) -> str:
    # BUG: crashes on None; also ignores empty string edge case
    return f"hello, {name.upper()}"


def greet_many(names):
    # Missing type hints; mutates input accidentally
    for i, n in enumerate(names):
        names[i] = greet(n)
    return names
