# Note for github versus gitlab:
I setup github as the customer-facing, clean version of the repo and the gitlab as the development version.
Copilot suggested the below steps to use in the future when developing so that we can keep customer gitub clean.
## Repository Setup

This project uses two repositories:

- GitLab is the development repository.
- GitHub is the clean, customer-facing repository.

Development branches, experiments, and incomplete work should remain in GitLab.
Only approved customer-facing `main` should be published to GitHub.

### First-Time Developer Setup

Clone the development repository from GitLab:

    git clone <GITLAB-REPOSITORY-URL>
    cd agenticaiaerospace

The GitLab repository will automatically be configured as `origin`.

Add the customer-facing GitHub repository as a second remote:

    git remote add github <GITHUB-REPOSITORY-URL>

Verify the configuration:

    git remote -v

You should see:

    origin  <GITLAB-REPOSITORY-URL> (fetch)
    origin  <GITLAB-REPOSITORY-URL> (push)
    github  <GITHUB-REPOSITORY-URL> (fetch)
    github  <GITHUB-REPOSITORY-URL> (push)

Verify that `main` tracks GitLab:

    git branch -vv

The `main` branch should show `origin/main` as its upstream.

If necessary, set it explicitly:

    git branch --set-upstream-to=origin/main main


## Normal Development

GitLab is the normal development remote.

Update `main`:

    git switch main
    git pull

Create development branches as needed:

    git switch -c feature/my-change

Push development work to GitLab:

    git push -u origin feature/my-change

Do not push development branches to GitHub.


## Publishing a Customer-Ready Version

Once approved changes have been merged into GitLab `main`:

    git switch main
    git pull origin main

Verify and test the customer-facing content.

Then publish `main` explicitly to GitHub:

    git push github main

Do not use:

    git push --all github
    git push --mirror github

GitHub should contain only the intentionally published customer-facing content.