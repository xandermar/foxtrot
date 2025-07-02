---
layout: post
title: "Build and Test Drupal 11 with Playwright"
date: 2025-07-07
categories: [drupal, playwright, github]
post_description: "Explains how to automate testing for Drupal 11 using GitHub Actions and Playwright. It covers setting up a workflow that triggers on updates to the master branch, builds a complete Drupal 11 environment with Docker, installs the site, and runs three sample Playwright end-to-end tests. This automation ensures code quality and site stability after each deployment, streamlining continuous integration for Drupal projects."
---

![Image](/assets/images/playwright.png){: .img-fluid style="max-height:720px; height:auto;" }

# Automated Drupal 11 Testing: CI/CD Superpowers with GitHub Actions & Playwright

Here’s a **GitHub Actions workflow** that triggers on updates to the `master` branch, spins up a Drupal 11 site using Docker, and then runs three sample [Playwright](https://playwright.dev/) tests. This script is meant to be run **in your repository root as `.github/workflows/drupal11-playwright.yml`**.

**Assumptions:**

* You have a standard Drupal 11 codebase (composer-based).
* You have a `tests/playwright` directory with your Playwright test scripts.
* You want to run three sample Playwright tests (you can swap the file names as needed).

---

```yaml
name: Build & Test Drupal 11 with Playwright

on:
  push:
    branches:
      - master

jobs:
  drupal-playwright:
    runs-on: ubuntu-latest
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_DATABASE: drupal
          MYSQL_USER: drupal
          MYSQL_PASSWORD: drupal
          MYSQL_ROOT_PASSWORD: root
        ports:
          - 3306:3306
        options: >-
          --health-cmd="mysqladmin ping --silent"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=5

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: 8.3
          extensions: mbstring, gd, pdo, pdo_mysql, curl, dom, zip, xml, json, bcmath, intl, opcache
          coverage: none

      - name: Install Composer dependencies
        run: composer install --no-interaction --prefer-dist

      - name: Start Drupal site (Dockerized Apache)
        run: |
          docker run -d --name drupal \
            --link ${{ job.services.mysql.id }}:mysql \
            -e MYSQL_HOST=mysql \
            -e MYSQL_DATABASE=drupal \
            -e MYSQL_USER=drupal \
            -e MYSQL_PASSWORD=drupal \
            -p 8080:80 \
            -v ${{ github.workspace }}:/var/www/html \
            drupal:11-apache
          sleep 60 # Give Drupal time to initialize

      - name: Site Install via Drush
        run: |
          composer require drush/drush --dev
          ./vendor/bin/drush si standard \
            --db-url=mysql://drupal:drupal@127.0.0.1:3306/drupal \
            --account-name=admin --account-pass=admin --yes

      - name: Check Drupal site is up
        run: curl --fail http://localhost:8080/

      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 20

      - name: Install Playwright
        run: |
          cd tests/playwright
          npm ci
          npx playwright install --with-deps

      - name: Run Playwright tests
        run: |
          cd tests/playwright
          npx playwright test test1.spec.ts
          npx playwright test test2.spec.ts
          npx playwright test test3.spec.ts
```

---

### **How it works:**

1. **Triggers** when `master` branch is updated.
2. **Spins up MySQL** as a service.
3. **Installs PHP/Composer/Drush** and sets up Drupal 11.
4. **Runs Drupal site** using Docker (official Drupal 11 image).
5. **Performs Drupal site install** with Drush.
6. **Checks the site** is responding at `http://localhost:8080/`.
7. **Installs Node.js & Playwright**.
8. **Runs 3 Playwright tests** from `tests/playwright`.

---

### **What you need to provide:**

* Place your Playwright tests in `tests/playwright/` (e.g., `test1.spec.ts`, `test2.spec.ts`, `test3.spec.ts`).
* Your repo should have a valid `composer.json` and `package.json` in the Playwright directory.

