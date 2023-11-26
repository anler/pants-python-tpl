from .name import get_name


def test_name() -> None:
    assert get_name() == "Hello <unknown>!"
