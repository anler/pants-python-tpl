import typer
from example_lib.name import get_name


def main(name: str) -> None:
    print(f"Importing {get_name(name)}")


if __name__ == "__main__":
    typer.run(main)
