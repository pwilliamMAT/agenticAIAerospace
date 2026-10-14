# Note for github versus gitlab:
I setup github as the customer-facing, clean version of the repo and the gitlab as the development version.
Copilot suggested the below steps to use in the future when developing so that we can keep customer gitub clean.

## Github repo:
https://github.com/pwilliamMAT/agenticAIAerospace

## Repository Workflow

GitLab is the development repository for this project.

- `origin` → GitLab (development)
- `github` → GitHub (customer-facing release)

Development branches and incomplete work remain in GitLab.
Only customer-ready content on `main` should be published to GitHub.

### Initial setup

git clone <GitLab repo>
cd agenticaiaerospace
git remote add github <GitHub repo>

### Normal development

git pull
git push

### Publish customer-ready main

git switch main