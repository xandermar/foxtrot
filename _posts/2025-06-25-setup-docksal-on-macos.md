---
layout: post
title: "How To Setup DOCKSAL on MacOS"
date: 2025-06-25
categories: [apple, docksal, docker]
post_description: "Learn how to set up Docksal on macOS with this step-by-step guide. Whether you're building Drupal, WordPress, or custom web applications, Docksal provides a fast, reliable, and containerized development environment. This article covers installation, project initialization, useful commands, and tips for troubleshooting. Perfect for developers looking to streamline local development on macOS."
---

![Image](/assets/images/docksal-setup.png){: .img-fluid style="max-height:720px; height:auto;" }



# How to Set Up Docksal on macOS

Docksal is a powerful tool that simplifies the setup and management of containerized development environments. It's especially popular among Drupal developers, but it supports any Docker-based stack. This guide walks you through setting up Docksal on macOS from scratch.

## Prerequisites

Before installing Docksal, ensure you have:

* A Mac running macOS 10.15 (Catalina) or newer
* Admin privileges on your machine
* [Homebrew](https://brew.sh/) installed

## Step 1: Install Docksal

Docksal can be installed using a single command:

```bash
curl -fsSL https://get.docksal.io | bash
```

This script will:

* Install required dependencies (Docker Desktop, VirtualBox, etc.)
* Install the `fin` command-line tool
* Configure system settings

> **Note**: If you already have Docker Desktop installed, Docksal will detect and use it. Otherwise, it will set up VirtualBox and Docksal’s custom VM (`docksal-vm`).

## Step 2: Restart Terminal

After installation, restart your terminal (or open a new tab) to begin using the `fin` command.

## Step 3: Create a New Docksal Project

Navigate to the directory where you want your project, then run:

```bash
mkdir myproject && cd myproject
fin init
```

You will be prompted to choose a stack (e.g., Drupal, WordPress, etc.). Docksal will then:

* Download necessary images
* Create a `.docksal` configuration
* Initialize a default database and web stack

## Step 4: Start the Project

To start the environment:

```bash
fin up
```

Then open your project in a browser:

```bash
fin project info
```

You’ll see the local site URL (e.g., `http://myproject.docksal`). Open it to access your project.

## Step 5: Common Commands

Here are a few useful `fin` commands:

* `fin status` – Check environment status
* `fin exec` – Run a shell inside the web container
* `fin restart` – Restart the environment
* `fin stop` – Stop the environment

## Step 6: (Optional) Set Up Xdebug

If you need debugging, enable it with:

```bash
fin config set --env XDEBUG_ENABLED=1
fin project restart
```

Then configure your IDE to listen on port `9003`.

## Troubleshooting

* **Permission Errors**: Try running `fin reset dns` or restarting the VM: `fin vm restart`
* **Docker Conflicts**: Ensure no other local containers are interfering with ports 80/443

Docksal offers a consistent, repeatable environment ideal for teams or solo developers working with Docker-based stacks. With `fin` managing the heavy lifting, getting started on macOS is quick and easy.

