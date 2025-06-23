---
layout: post
title: "How To Setup LANDO on MacOS"
date: 2025-06-27
categories: [apple, lando, docker]
post_description: "Learn how to set up Lando on macOS for fast, Docker-based local development. This step-by-step guide walks you through installing Docker, configuring Lando, initializing a project (like Drupal or WordPress), and using helpful Lando commands to streamline your development workflow. Perfect for developers looking to simplify their local environments on macOS."
---

![Image](/assets/images/lando-setup.png){: .img-fluid style="max-height:720px; height:auto;" }

# How to Set Up Lando on macOS

**Lando** is a powerful local development tool built on Docker that simplifies setting up development environments for web applications like Drupal, WordPress, Laravel, Node.js, and more. If you're a developer on macOS looking to streamline your workflow, follow this guide to install and configure Lando.

---

## ✅ Prerequisites

Before you begin, ensure you have the following:

* **macOS 10.15+**
* **Admin access** to install software
* **Homebrew** (optional, but helpful)
* **Docker Desktop** (required)

---

## 🔧 Step-by-Step Installation

### 1. Install Docker Desktop

Lando runs on Docker, so it must be installed first.

* Download Docker for Mac: [https://www.docker.com/products/docker-desktop/](https://www.docker.com/products/docker-desktop/)
* Open the `.dmg` file and drag Docker to Applications.
* Launch Docker from Applications and ensure it's running in your menu bar.
* You may be asked to authorize privileged access — approve it.

### 2. Install Lando

Download the latest Lando installer:

* Visit [https://docs.lando.dev/core/v3/installation/](https://docs.lando.dev/core/v3/installation/)
* Click the **macOS download** link and open the `.pkg` installer.
* Follow the installation steps.

> 📝 **Tip:** You can also install via Homebrew:

```bash
brew install lando
```

### 3. Verify Installation

Open Terminal and run:

```bash
lando version
```

If successful, you’ll see the installed Lando version, e.g.:

```
Lando version: 3.17.0
```

---

## 🚀 Creating a New Lando Project

### 1. Create a Project Directory

```bash
mkdir my-lando-app
cd my-lando-app
```

### 2. Initialize a Lando App

```bash
lando init
```

You’ll be prompted to choose:

* A recipe (like `drupal`, `wordpress`, `laravel`, `lamp`, etc.)
* A name
* A codebase directory (use `.` for current)

Example:

```bash
? From where should we get your app's codebase? Use the current directory
? What recipe do you want to use? drupal10
? What do you want to call this app? my-lando-site
```

### 3. Start Lando

```bash
lando start
```

Lando will:

* Pull the necessary Docker images
* Set up your environment
* Give you URLs for your local site

### 4. Access Your App

After the build is complete, you’ll see output like:

```
BOOMSHAKALAKA!!! Your app has started up correctly.
Visit it in your browser: http://my-lando-site.lndo.site
```

---

## 🧪 Common Commands

* `lando start` — Starts the app
* `lando stop` — Stops the app
* `lando destroy` — Deletes the environment
* `lando rebuild` — Rebuilds the environment
* `lando ssh` — Shell into the container
* `lando drush`, `lando composer`, etc. — Run project-specific tools

---

## 🧼 Uninstalling Lando (optional)

To remove Lando:

```bash
brew uninstall lando   # if installed with Homebrew
sudo rm -rf /usr/local/bin/lando
sudo rm -rf ~/.lando
```

Also uninstall Docker Desktop if desired via its Uninstaller.



Lando makes local development easy and repeatable on macOS. With built-in support for popular frameworks and Dockerized environments, it removes the hassle of manual setup and lets you focus on development.

