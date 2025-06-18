---
layout: post
title: "Setup a Drupal 11 Website from Scratch"
date: 2025-06-18
categories: [drupal, web-development, programming]
post_description: "Learn how to install and configure a Drupal 11 website from scratch using Composer."
---

![Image](/assets/images/setup-drupal-11.jpg){: .img-fluid style="max-height:720px; height:auto;" }

## Setting up a **Drupal 11** website from scratch involves several steps, including preparing your environment, downloading Drupal, configuring it, and verifying that everything works. Here's a complete step-by-step guide using Composer, which is the **recommended method** for managing modern Drupal installations.

---

## ✅ Prerequisites

Make sure you have the following installed:

* PHP 8.2 or later (PHP 8.3 recommended)
* Composer 2.5 or later
* MySQL 8.0+ or MariaDB 10.4+
* Apache or Nginx
* Drush (optional but useful)
* A local development stack (e.g. [DDEV](https://ddev.readthedocs.io), [Lando](https://docs.lando.dev), or [Docksal](https://docs.docksal.io))

---

## 🚀 Step-by-Step Setup

### 1. **Create a New Drupal 11 Project**

```bash
composer create-project drupal/recommended-project:^11 my_site_name
cd my_site_name
```

This creates a Drupal 11 site with standard directory structure and Composer-based dependency management.

---

### 2. **Set File Permissions**

```bash
mkdir -p web/sites/default/files
chmod -R 755 web/sites/default/files
cp web/sites/default/default.settings.php web/sites/default/settings.php
chmod 644 web/sites/default/settings.php
```

---

### 3. **Create a Database**

Create a MySQL/MariaDB database:

```sql
CREATE DATABASE drupal11 CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
```

Take note of:

* Database name
* Username/password
* Host (usually `localhost`)

---

### 4. **Start Local Server (Optional)**

If you're not using DDEV/Lando, you can use PHP's built-in server:

```bash
php -S localhost:8888 -t web
```

Or configure Apache/Nginx to point to the `web/` folder.

---

### 5. **Run Drupal Installer**

Open browser:
`http://localhost:8888` (or your virtual host)

Go through the installer:

* Choose language
* Choose standard profile
* Provide database credentials
* Set admin username, password, and site email

---

### 6. **(Optional) Install Drush**

```bash
composer require drush/drush
vendor/bin/drush status
```

You can now use Drush to manage your site from the command line.

---

### 7. **(Optional) Enable Clean URLs with `.htaccess`**

If using Apache, make sure `.htaccess` is respected and `mod_rewrite` is enabled.

---

### 8. **(Optional) Set Up Git**

```bash
git init
echo "/web/sites/default/settings.php" >> .gitignore
echo "/web/sites/default/files" >> .gitignore
git add .
git commit -m "Initial Drupal 11 installation"
```

---

## 🧪 Verify Installation

Check:

* Admin login: `/user/login`
* Status report: `/admin/reports/status`
* Cron: `/admin/config/system/cron`

---

## ✅ Optional Modules

You might want to install some popular contrib modules:

```bash
composer require drupal/admin_toolbar
composer require drupal/pathauto
composer require drupal/token
composer require drupal/redirect
```

Enable them with:

```bash
vendor/bin/drush en admin_toolbar pathauto token redirect -y
```

