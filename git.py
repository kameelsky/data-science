from subprocess import run
from sys import argv

prompt = argv[1:]

def git(prompt: list) -> None:
    message = " ".join(prompt)
    print(f"Commit message: {message}")
    run("git add .", shell=True)
    run(f"git commit -m '{message}'", shell=True)
    run("git push -u origin main", shell=True)

def main(prompt: list) -> None:
    if len(prompt) > 0:
        git(prompt=prompt)
    else:
        print("No message provided.")
        exit()

if __name__=="__main__":
    main(prompt=prompt)