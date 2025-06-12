- Create a script to populate the repo with the current state -> updating the committers requires a manual action
- Automatically run the script that populates members every day. If there's a deviation, make a PR.
- Run the script that checks for inactivity every month and create PRs as appropriate

App permissions:
- Organisation: Members read only
- Repository: Pull requests read write, Contents read write

Install on only the nixpkgs-committers repo
