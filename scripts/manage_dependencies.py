import argparse
import json
import os
import subprocess
import sys

deps_file = f"{os.path.expanduser('~')}/dotfiles/deps.json"


def get_latest_rev(url, branch=None):
    command = " ".join(
        [
            "git",
            "ls-remote",
            url,
            f"refs/heads/{branch}" if branch else "| rg -e 'refs/heads/(main|master)$'",
        ]
    )
    output = subprocess.check_output(command, shell=True, text=True)
    output_parts = output.split()
    latest_commit_rev = output_parts[0]
    branch_ref = output_parts[1].split("/")[-1]

    return latest_commit_rev, branch_ref


def get_hash(url, branch, rev, sparse_checkout):
    has_sparse_checkout = 1 if sparse_checkout else 0
    command = ["nurl", url, rev, "-f", "fetchgit", "-A", "branchName", branch]
    if has_sparse_checkout == 1:
        sparse_checkout_str = "["
        for sc in sparse_checkout:
            sparse_checkout_str += f'"{sc}"'
        sparse_checkout_str += "]"
        command.append("-a")
        command.append("sparseCheckout")
        command.append(sparse_checkout_str)

    try:
        output = subprocess.check_output(command, text=True)
    except subprocess.CalledProcessError as e:
        print("Command:", " ".join(command))
        print("Error:", e)
        sys.exit()

    lines = output.strip().split("\n")
    hash = lines[-3 - has_sparse_checkout].split(" ")[-1][1:-2]
    return hash


def add_dependency():
    if len(sys.argv) < 4:
        raise ValueError("Usage: python manage_dependencies.py add <name> <url>")

    name = sys.argv[2]
    url = sys.argv[3]
    branch = None
    sparse_checkout = None
    rev = None

    if len(sys.argv) >= 5:
        parser = argparse.ArgumentParser(description="Add dependency")
        parser.add_argument("-b", "--branch", type=str, help="branch name")
        parser.add_argument("-r", "--rev", type=str, help="rev")
        parser.add_argument(
            "-s", "--sparse-checkout", nargs="+", type=str, help="sparse checkout"
        )
        args, _ = parser.parse_known_args()

        if args.branch:
            branch = args.branch
        if args.sparse_checkout:
            sparse_checkout = args.sparse_checkout
        if args.rev:
            rev = args.rev

    if not rev or not branch:
        latest_rev, branch_ref = get_latest_rev(url, branch)
        if not rev:
            rev = latest_rev
        branch = branch_ref

    hash = get_hash(url, branch, rev, sparse_checkout)

    with open(deps_file, "r") as file:
        data = json.load(file)
    data[name] = {
        "url": url,
        "branchName": branch,
        "rev": rev,
        "hash": hash,
    }
    if sparse_checkout:
        data[name]["sparseCheckout"] = sparse_checkout

    with open(deps_file, "w") as file:
        sorted_data = dict(sorted(data.items()))
        json.dump(sorted_data, file, indent=2)

    print(f"Dependency {name} added successfully!")


def update_dependencies():
    with open(deps_file, "r") as file:
        data = json.load(file)

    for item in data:
        url = data[item]["url"]
        branch = data[item]["branchName"]
        rev = data[item]["rev"]
        latest_rev, _ = get_latest_rev(url, branch)
        hash = data[item]["hash"]

        if rev == latest_rev and hash != "":
            continue

        sparse_checkout = (
            data[item]["sparseCheckout"] if "sparseCheckout" in data[item] else None
        )
        hash_value = get_hash(url, branch, rev, sparse_checkout)
        data[item]["rev"] = latest_rev
        data[item]["hash"] = hash_value

    with open(deps_file, "w") as file:
        sorted_data = dict(sorted(data.items()))
        json.dump(sorted_data, file, indent=2)

    print("Dependencies' hash and rev updated successfully!")


def main():
    if len(sys.argv) < 2:
        raise ValueError("Usage: python manage_dependencies.py <add|update|remove>")

    action = sys.argv[1]

    if action == "add":
        add_dependency()
    elif action == "update":
        update_dependencies()
    else:
        raise ValueError("Invalid action. Available options: <add|update>")


if __name__ == "__main__":
    main()
