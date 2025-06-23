---
layout: post
title: "How To Setup DDEV on MacOS"
date: 2025-06-23
categories: [apple, ddev, docker]
post_description: "Learn how to install and configure DDEV on macOS to create a powerful local development environment using Docker. This step-by-step guide walks you through installing Homebrew, Docker Desktop, and DDEV, setting up your first project (e.g., Drupal, WordPress, or Laravel), and running your site at a secure local .ddev.site domain. Perfect for developers looking to streamline their local workflow on macOS."
---

![Image](/assets/images/ddev-setup.png){: .img-fluid style="max-height:720px; height:auto;" }

## Here's how to set up **DDEV** on macOS for local web development (e.g., Drupal, WordPress, Laravel):

---

## ✅ Step-by-Step DDEV Setup on macOS

### 1. **Install Homebrew (if not installed)**

Open Terminal and run:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

---

### 2. **Install Docker Desktop**

DDEV relies on Docker. Download and install it:

* Visit: [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)
* Install and **start Docker Desktop**
* Confirm it's running:
  You should see the Docker whale icon in the menu bar.

---

### 3. **Install DDEV via Homebrew**

```bash
brew install ddev
```

Verify installation:

```bash
ddev version
```

---

### 4. **Create Your Project Folder**

```bash
mkdir mysite
cd mysite
```

(Optional) If you’re using a CMS like Drupal, clone your repo or install CMS here.

---

### 5. **Start DDEV Project**

```bash
ddev config
```

You'll be prompted for:

* Project name
* Project type (e.g., `drupal10`, `wordpress`, `laravel`, etc.)
* Docroot location (usually `web/` or `htdocs/`)
* Project URL (defaults to `https://<project>.ddev.site`)

Example answers for a Drupal 10 site:

```
Project name: mysite
Project type: drupal10
Docroot: web
```

---

### 6. **Start DDEV and Install CMS**

```bash
ddev start
```

If using Drupal:

```bash
ddev composer create drupal/recommended-project
```

Or import existing site files and database.

---

### 7. **Access Site**

Once started, DDEV shows the local site and admin URLs, e.g.:

```
https://mysite.ddev.site
```

---

### 8. **Useful DDEV Commands**

```bash
ddev stop            # Stop the project
ddev restart         # Restart the project
ddev ssh             # SSH into the container
ddev import-db       # Import a database
ddev launch          # Open the site in your browser
```

