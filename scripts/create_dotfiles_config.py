import json
import os

home_dir = os.path.expanduser("~")
config_template = f"{home_dir}/dotfiles/templates/dotfiles.json"
config_output = f"{home_dir}/dotfiles/dotfiles.json"


def replace_placeholder():
    with open(config_template, "r") as file:
        data = json.load(file)

    username = input("Enter username: ")
    git_name = input("Enter git name: ")
    email = input("Enter email: ")

    data["username"] = username
    data["gitName"] = git_name
    data["email"] = email

    with open(config_output, "w") as file:
        json.dump(data, file, indent=2)

    print("Dotfiles config created successfully.")


if __name__ == "__main__":
    replace_placeholder()
