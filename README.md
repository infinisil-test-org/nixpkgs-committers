# Nixpkgs committers

This repository publicly tracks the [current members](./members) and [changes](../../commits/main/members)
of the [Nixpkgs Committers](https://github.com/orgs/nixos/teams/nixpkgs-committers) team,
whose members have write access to [Nixpkgs](https://github.com/nixos/nixpkgs).

The [Nixpkgs commit delegators](https://github.com/orgs/NixOS/teams/commit-bit-delegation)
maintain the member list in this repository.

## Nominations

To nominate yourself or somebody else:
1. Create an empty `members/<GITHUB_HANDLE>` file ([direct GitHub link](/../../new/main/members?filename=%3CGITHUB_HANDLE%3E))
2. Create a PR with the change with the motivation in the PR description

Such nominations are also automatically announced in [this issue](https://github.com/NixOS/nixpkgs/issues/999999), which you can subscribe to for updates.

You can see all current nominations [here](/../../issues?q=state%3Aopen%20label%3Anomination)

## Semi-automatic synchronisation

Every day, [a GitHub Action workflow](./.github/workflows/sync.yml) runs
to synchronise the members of the GitHub team with the member list in this repository.
If they don't match, an automated PR is created,
which should be merged by the Nixpkgs commit delegators to reconcile the mismatch.

## Semi-automatic retirement

Every day, [a GitHub Action workflow](./.github/workflows/retire.yml) runs
to check if any Nixpkgs committers have not used their commit access within the last year,
in which case an automated PR is created to remove them from the member list.
This is according to [RFC 55](https://github.com/NixOS/rfcs/blob/master/rfcs/0055-retired-committers.md)
and the SC-approved [amendment](https://github.com/NixOS/org/issues/91).

The PR will ping the user and inform them that it will by default be merged and implemented in one month.
If the PR is still open one month later,
an automated comment will be posted with the next steps for the Nixpkgs commit delegators.

## Automation setup

Automation depends on a GitHub App with the following permissions:
- Organisation: Members read only (to be able to read the team members)
- Repository: Pull requests read write, Contents read write (to be able to create PRs in this repository)

The GitHub App should only be installed on this repository.
To give the workflows access to the GitHub App:
- Configure the App ID as the repository _variable_ `APP_ID`
- Configure the private key as the repository _secret_ `PRIVATE_KEY`
