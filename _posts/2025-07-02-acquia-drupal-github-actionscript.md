---
layout: post
title: "Acquia, Drupal 11: Example GitHub Actions workflow"
date: 2025-07-02
categories: [drupal, acquia, github]
post_description: "This article provides a step-by-step guide for automating Drupal 11 deployments to Acquia Cloud using GitHub Actions. It covers how to configure your workflow to build your site, compile theme assets with Gulp, push updates to your Acquia Git repository, and automatically execute critical Drush post-deploy commands (drush cim -y, drush updb -y, and drush cr) on your Acquia environment. This streamlined process ensures your site remains up-to-date, reduces manual deployment errors, and accelerates your Drupal development workflow."
---

![Image](/assets/images/github.jpg){: .img-fluid style="max-height:720px; height:auto;" }

# Seamless Drupal 11 Deployments: Automating Your Acquia Workflow with GitHub Actions


Below is an example of a **GitHub Actions workflow** that triggers when the `master` branch is updated, builds your **Drupal 11** site (runs `composer install` and `gulp build` in your theme), then deploys to Acquia, and finally runs the required **Drush** post-deploy commands (`drush cim -y`, `drush updb -y`, `drush cr`).

**Assumptions:**

* You’re using **Acquia Cloud** with Git deployment (push to remote Acquia Git repo).
* `gulp` and dependencies are installed in your theme.
* Acquia remote is set up as a Git remote (e.g., `acquia`).
* Your Acquia Drush alias (for remote commands) is e.g. `@myenv`.
* GitHub secrets contain your Acquia repo **SSH\_PRIVATE\_KEY** for authentication.

You may need to adjust names, secrets, and Drush aliases to your project.

---

```yaml
name: Deploy to Acquia on Master Update

on:
  push:
    branches:
      - master

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    env:
      THEME_PATH: themes/custom/my_theme

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up SSH key for Acquia
        uses: webfactory/ssh-agent@v0.9.0
        with:
          ssh-private-key: ${{ secrets.SSH_PRIVATE_KEY }}

      - name: Set up PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.2'

      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'

      - name: Install Composer dependencies
        run: composer install --no-interaction --prefer-dist --optimize-autoloader

      - name: Install Gulp dependencies and build theme
        run: |
          cd $THEME_PATH
          npm ci
          npx gulp build

      - name: Configure git for pushing to Acquia
        run: |
          git config --global user.email "github-actions@github.com"
          git config --global user.name "GitHub Actions"
          # Add Acquia remote if not present
          if ! git remote | grep acquia; then
            git remote add acquia "$ACQUIA_REMOTE_REPO"
          fi

        env:
          ACQUIA_REMOTE_REPO: ${{ secrets.ACQUIA_REMOTE_REPO }}

      - name: Push code to Acquia
        run: |
          git push acquia master

      - name: Run Drush post-deploy on Acquia
        run: |
          ssh $ACQUIA_SSH "cd $ACQUIA_DOCROOT && drush cim -y && drush updb -y && drush cr"
        env:
          ACQUIA_SSH: ${{ secrets.ACQUIA_SSH }}
          ACQUIA_DOCROOT: "/var/www/html/{sitename}.{env}/docroot" # Replace with your Acquia docroot path

```

---

### **Required GitHub Secrets:**

* `SSH_PRIVATE_KEY`: SSH key with access to both the Acquia Git repo and SSH.
* `ACQUIA_REMOTE_REPO`: Your Acquia Git repo URL, e.g. `ssh://srv.bldr@svn-1234.prod.hosting.acquia.com:1234/myrepo.git`
* `ACQUIA_SSH`: SSH string for your Acquia environment, e.g. `user@server.acquia-sites.com`
* (Optional: You can also store `ACQUIA_DOCROOT` as a secret or hardcode it.)

---

### **NOTES:**

* **Replace** the values in `ACQUIA_DOCROOT` and `ACQUIA_SSH` with your actual Acquia details.
* If you have Acquia Cloud hooks, you may want to run Drush commands via those instead.
* If you have a **multidev** environment, adjust branch/environment names accordingly.
* If you want to run Drush via an Acquia Cloud API, use `acli` or `acapi` actions.


