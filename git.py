from subprocess import run
from sys import argv

prompt = argv[1:]

def git(prompt: list) -> None:
    message = " ".join(prompt)
    while True:
        input_ = input(f"\n>>> Commit message: {message}\n\n>>> Do you want to proceed? (y/n): ")
        if input_.lower() == "y":
            run(f"git add . && git commit -m '{message}' && git push -u origin main", shell=True)
            break
        else:
            break

def main(prompt: list) -> None:
    if len(prompt) > 0:
        git(prompt=prompt)
    else:
        print("\n>>> No message provided.\n>>> git status\n")
        run(f"git status", shell=True)
        exit()

if __name__=="__main__":
    main(prompt=prompt)