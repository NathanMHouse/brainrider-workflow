# Recipe file

# 1.0  default
# 2.0  wordpress-download
# 3.0  wordpress-extract
# 4.0  wp-cli
# 5.0  database
# 6.0  install
# 7.0  theme-config
# 8.0  plugins-config
# 9.0  workflow
	# 9.1  workflow-bower
	# 9.2  workflow-gulp
	# 9.3  workflow-repo
# 10.0 complete
# 11.0 build
# 12.0 db-localtoremote
# 13.0 clean
	# 13.1 clean-files
	# 13.2 clean-db
# 14.0 help

# Include make options file
include make-config.yml

# Recipe: 1.0 - default (i.e make)
default: wordpress-extract wp-cli database install theme-config plugins-config workflow complete

# Recipe: 2.0 - wordpress-download
# Downloads latest version of WordPress.
wordpress-download:
	@echo
	@echo "$(IMPORTANT)Task | wordpress-download:$(DEFAULT)" \
	"Downloading the latest version of WordPress..."
	$(AT)curl $(VERBOSE) -LOk http://wordpress.org/latest.tar.gz
	@echo "$(SUCCESS)Success:$(DEFAULT) Download complete."
	@echo

# Recipe: 3.0 - wordpress-extract
# Extracts WordPress files from archive and removes extraneous content.
wordpress-extract: wordpress-download
	@echo "$(IMPORTANT)Task | wordpress-extract:$(DEFAULT)" \
	"Extracting WordPress files..."
	tar $(VERBOSE) -zxf latest.tar.gz
	$(AT)rm -rf wordpress/wp-content
	$(AT)mv wordpress/* ./
	$(AT)rm -rf latest.tar.gz wordpress license.txt readme.html \
	wp-config-sample.php wp-content/plugins/akismet wp-content/plugins/hello.php
	$(AT)mkdir -p wp-content/plugins
	$(AT)echo "$(SUCCESS)Success:$(DEFAULT) Extraction complete."
	@echo

# Recipe: 4.0 - wp-cli
# Downloads wp-cli, changes rights, and moves destination.
wp-cli:
	@echo "$(IMPORTANT)Task | wp-cli:$(DEFAULT) Installng WP-CLI..."
	$(AT)mkdir -p wp-cli && cd wp-cli; \
	curl -LOk $(VERBOSE) https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar; \
	chmod +x wp-cli.phar
	sudo mv wp-cli/wp-cli.phar /usr/local/bin/wp
	$(AT)ln -s ./wp-cli/bin/wp wp
	@echo "$(SUCCESS)Success:$(DEFAULT) WP-CLI installed and set up."
	@echo

# Recipe: 5.0 - database
# Creates database. Name generated dynamical based on working directory 
# (e.g br_$(working_directory)).
database:
	@echo "$(IMPORTANT)Task | database:$(DEFAULT) Creating database $(DB_NAME)." \
	"Enter database password for root to continue."
	$(AT)mysql -u$(DB_USER) -p -e "CREATE DATABASE $(DB_NAME)"
	@echo "$(SUCCESS)Success:$(DEFAULT) $(DB_NAME) database created."
	@echo

# Recipe: 6.0 - install
# Sets up custom wp-config, performs WordPress install, updates options, 
# performs permalink rewrite, generates .htaccess, and removes extraneous posts/pages.
install:
	@echo "$(IMPORTANT)Task | install:$(DEFAULT) Setting up wp-config file..."

# Create wp-config
	$(AT)wp core config --dbname=$(DB_NAME) --dbuser=$(DB_USER) --dbpass=$(DB_PASS)

# Installing WordPress
	@echo "Installing WordPress at $(PWD)..."
	$(AT)wp core install --url=$(THEME_NAME).dev --admin_user="$(WP_USER)" \
	--admin_password="$(WP_PASS)" --admin_email="$(WP_EMAIL)" --title="$(WP_TITLE)"

# Update options, perform rewrite, and delete posts/pages
	$(AT)wp option update blogdescription "$(WP_DESCRIPTION)" --quiet
	$(AT)wp rewrite structure --hard "/blog/%category%/%postname%/"
	$(AT)wp post delete 1 --force --quiet
	$(AT)wp post delete 2 --force --quiet
	@echo

# Recipe: 7.0 - theme-config
# Downloads and activates brainrider-boilerplate theme and updates theme info in style file.
theme-config:
	@echo "$(IMPORTANT)Task | theme-config:$(DEFAULT)" \
	"Downloading boilerplate theme..."
	$(AT)mkdir -p wp-content/themes

# Download Brainrider Boilerplate theme
	$(AT)git clone https://gocactus@bitbucket.org/gocactus-inc/brainrider-boilerplate.git \
	wp-content/themes/$(THEME_NAME) $(VERBOSE)

# Remove Brainrider Boilerplate theme git files
	$(AT)cd wp-content/themes/$(THEME_NAME); \
	rm -rf .git .gitignore README.md
	@echo "$(SUCCESS)Success:$(DEFAULT) Boilerplate download complete."

# Update theme info in style file
	@echo "Updating style.scss file..."
	$(AT)cd ./wp-content/themes/$(THEME_NAME)/src/scss; \
	sed -i.bak 's/[Bb]rainrider.[bB]oilerplate/$(THEME_NAME)/g' \
	style.scss ../../style.css; \
	sed -i.bak 's#Theme URI:*#Theme URI: $(THEME_URI)#g' \
	style.scss ../../style.css; \
	sed -i.bak 's/Description:.*/Description: $(THEME_DESC)/g' \
	style.scss ../../style.css; \
	sed -i.bak 's/Author:.*/Author: $(THEME_AUTHOR)/g' \
	style.scss ../../style.css; \
	sed -i.bak 's#Author URI:.*#Author URI: $(THEME_AUTHOR_URI)#g' \
	style.scss ../../style.css; \
	rm -rf style.scss.bak ../../style.css.bak

# Activate theme
	@echo "Activating theme..."
	$(AT)wp theme activate $(THEME_NAME)
	@echo

# Recipe: 8.0 - plugins-config
# Installs all plugins, including premium versions of ACF Pro, iThemes Security Pro,
# and Brainrider Resource Centre.
plugins-config:
	@echo "$(IMPORTANT)Task | plugins-config:$(DEFAULT)" \
	"Installing premium plugins..."

# Install iThemes Security Pro
	@echo "Installing iThemes Security Pro...(Disabled)"
	#$(AT)cp ./ithemes-security-pro.zip ./wp-content/plugins/
	#$(AT)wp plugin install ./wp-content/plugins/ithemes-security-pro.zip \
	--activate
	#$(AT)rm -rf ./wp-content/plugins/ithemes-security-pro.zip

# Install ACF Pro
	@echo "Installing ACF Pro..."
	$(AT)curl $(VERBOSE) -Lo  acf-pro.zip "http://connect.advancedcustomfields.com/index.php?"\
	"p=pro&a=download&k=$(ACF_KEY)"
	$(AT)mv acf-pro.zip ./wp-content/plugins
	$(AT)wp plugin install ./wp-content/plugins/acf-pro.zip --activate
	$(AT)rm -rf ./wp-content/plugins/acf-pro.zip

# Install Brainrider Resource Centre
	@echo "Installing Brainrider Resource Centre..."
	$(AT)git clone https://gocactus@bitbucket.org/gocactus-inc/brainrider-resource-centre-plugin.git \
	$(VERBOSE)
	$(AT)mv ./brainrider-resource-centre-plugin/dist/brainrider-resource-centre.zip \
	./wp-content/plugins
	$(AT)rm -rf ./brainrider-resource-centre-plugin
	$(AT)wp plugin install ./wp-content/plugins/brainrider-resource-centre.zip \
	--activate
	$(AT)rm -rf ./wp-content/plugins/brainrider-resource-centre.zip

# Install General Project Plugin
	@echo "Installing general $(THEME_NAME) plugin..."
	mkdir -p wp-content/plugins/$(THEME_NAME)-plugin
	$(AT)printf "<?php\n/*\nPlugin Name: $(WP_TITLE) Website Plugin\n" \
	> wp-content/plugins/$(THEME_NAME)-plugin/$(THEME_NAME)-plugin.php 
	$(AT)printf "Description: Site specific code for $(WP_TITLE)\n*/" \
	>> wp-content/plugins/$(THEME_NAME)-plugin/$(THEME_NAME)-plugin.php

# Install non-premium plugins
	@echo "Installing other miscellaneous plugins..."
	$(AT)wp plugin install add-to-any advanced-access-manager \
	breadcrumb-navxt broken-link-checker duplicate-post enable-media-replace \
	googleanalytics query-monitor regenerate-thumbnails relevanssi \
	simple-301-redirects svg-support taxonomy-terms-order theme-check \
	wordpress-seo wp-all-import wp-optimize yet-another-related-posts-plugin \
	acf-content-analysis-for-yoast-seo --activate
	@echo

# Update all plugins
	$(AT)wp plugin update --all
	@echo

# Recipe: 9.0 - workflow
# Parent workflow task (runs workflow-repo, workflow-bower, and workflow-dev).
workflow: workflow-bower workflow-gulp workflow-repo

# Recipe: 9.1 - workflow-bower
# Installs required libraries (e.g. jQuery etc.).
workflow-bower:
	@echo "$(IMPORTANT)Task | workflow-bower:$(DEFAULT)" \
	"Installing Bower libraries..."
	$(AT)cd wp-content/themes/$(THEME_NAME)/src; \
	bower install
	@echo "$(SUCCESS)Success:$(DEFAULT) Libraries installed."
	@echo

# Recipe: 9.2 - workflow-gulp
# Copies custom gulp configuration to src and install required node modules.
workflow-gulp:
	@echo "$(IMPORTANT)Task | workflow-gulp:$(DEFAULT)" \
	"Setting Gulp configuration..."
	$(AT)cp gulp-config.js ./wp-content/themes/$(THEME_NAME)/src
	@echo "Installing node modules..."
	$(AT)cd wp-content/themes/$(THEME_NAME)/src; \
	npm install && npm update
	@echo "$(SUCCESS)Success:$(DEFAULT) Node modules installed."
	@echo
	@echo "Running gulp build task..."
	$(AT)cd wp-content/themes/$(THEME_NAME)/src; \
	gulp regex; \
	gulp build 
	@echo

# Recipe: 9.3 - workflow-repo
# Initiate bitbucket repository, create ignore file and README file,
# and perform initial commit.
workflow-repo:
	@echo "$(IMPORTANT)Task | workflow-repo:$(DEFAULT) Setting up repository..."

# Create project README.md
	$(AT)printf "# $(THEME_NAME) README #\n\n" \
	> README.md 
	$(AT)printf "This document should be updated to provide the details necessary to work on the project.\n\n" \
	>> README.md
	$(AT)printf "### What is this repository for? ###\n\n" \
	>> README.md
	$(AT)printf "* Quick summary\n* Version\n\n" \
	>> README.md
	$(AT)printf "### How do I get set up? ###\n\n" \
	>> README.md
	$(AT)printf "* Summary of set up\n* Configuration\n* Dependencies\n* Database configuration\n* Deployment instructions\n\n" \
	>> README.md
	$(AT)printf "### Contribution guidelines ###\n\n" \
	>> README.md
	$(AT)printf "* Code review\n* Other guidelines\n\n" \
	>> README.md
	$(AT)printf "### Who do I talk to? ###\n\n" \
	>> README.md
	$(AT)printf "* Repo owner or admin\n* Other community or team contact\n" \
	>> README.md

# Create .gitignore file
	@echo "Creating .gitignore file..."
	$(AT)printf "# Ignore contents at root except for wp-content and project README" \
	>> .gitignore
	$(AT)printf "\n/*\n!wp-content/\n!README.md\n\n" \
	>> .gitignore
	$(AT)printf "# Ignore contents of wp-content except themes/uploads/plugins" \
	>> .gitignore
	$(AT)printf "\nwp-content/*\n!wp-content/uploads/\n!wp-content/themes/\n!wp-content/plugins/\n\n" \
	>> .gitignore
	$(AT)printf "# Ignore content of themes except project theme" \
	>> .gitignore
	$(AT)printf "\nwp-content/themes/*\n!wp-content/themes/$(THEME_NAME)/\n\n" \
	>> .gitignore
	$(AT)printf "# Ignore src folder\nwp-content/themes/$(THEME_NAME)/src\n" \
	>> .gitignore

# Set up new repo, initiate git in folder and add/commit files.
	@echo "Creating new remote repo..."
	$(AT)curl $(verbose) --user $(REPO_USER):$(REPO_PASS) -X POST -H "Content-Type: application/json" \
	-d '{"scm": "git", "project": {"key": "$(REPO_PROJECT_KEY)"}, "is_private": true}' \
	https://api.bitbucket.org/2.0/repositories/$(REPO_TEAM)/$(THEME_NAME)
	$(AT)git init
	$(AT)git add .
	$(AT)git commit -m 'initial commit'

# Connect to remote repo and push intial commit
	@echo "Pushing initial commit..."
	$(AT)git remote add origin $(REPO_URL)
	$(AT)git push -u origin master
	@echo "$(SUCCESS)Success:$(DEFAULT) Repository setup complete."

# Recipe: 10.0 - complete
# Display instructions on next steps and remove varous setup files.
complete:
	@echo
	@echo "$(IMPORTANT)Task | complete:$(DEFAULT) Install complete."
	@echo
	@echo "Removing setup files..."
	$(AT) rm -rf gulp-config.js ithemes-security-pro.zip
	@echo
	@echo "$(IMPORTANT)Project Details:$(DEFAULT)"
	@echo "> $(LABEL)Database$(DEFAULT):\t\t$(DB_NAME)"
	@echo "> $(LABEL)URL$(DEFAULT):\t\t\t$(THEME_NAME).dev"
	@echo "> $(LABEL)WordPress Path$(DEFAULT):\t$(PWD)"
	@echo "> $(LABEL)Theme$(DEFAULT):\t\t$(THEME_NAME)"
	@echo "> $(LABEL)Repo$(DEFAULT):\t\t\t$(REPO_URL)"
	@echo
	@echo  "Develop within src folder, outputting dist-ready files to root via" \
	"\ndefault gulp task and commit ongoing theme development to project repo."
	@echo

# Recipe: 11.0 - build
# Runs gulp build task from root of project.
build:
	@echo "$(IMPORTANT)Task | build:$(DEFAULT)" \
	"Running Gulp build task - moving generated files to root..."
	$(AT)cd wp-content/themes/$(THEME_NAME)/src; \
	gulp build

# Recipe: 12.0 - db-localtoremote
# Ovewrites remote database with local (exluding wp_users, wp_options, and wp_usermeta)
db-localtoremote:
	@echo "$(IMPORTANT)Task | db-localtoremote:$(DEFAULT)" \
	"$(WARNING)Preparing to overwrite remote database with local database...$(DEFAULT)"

# Confirm overwrite (only continue on Y/y)
	$(AT)while [ -z "$$CONFIRM_DEL" ]; do \
		read -rp "Are you sure you want to ovewrite all remote database values with those from local? Only wp_options, wp_users, and wp_usermeta will be retained.[y/n]: " \
		CONFIRM_DEL; \
	done; \
	[ $$CONFIRM_DEL = "y" ] || \
	[ $$CONFIRM_DEL = "Y" ] || \
	(echo "Exiting. No database values were ovewritten."; exit 1)

# Export local database (exlude wp_options, wp_users, and wp_usermeta tables)
	$(AT)wp db export --compatible=mysql40 \
	--exclude_tables=wp_options,wp_users,wp_usermeta \
	'$(DB_NAME).sql'

# Perform sed search and replace to remove deprecated 'TYPE'
	$(AT)sed -i.bak 's/TYPE=InnoDB/ENGINE=InnoDB/g' $(DB_NAME).sql

# Copy the database to the remove server
	@echo "Copying local database to remote server..."
	$(AT)scp $(DB_NAME).sql $(RM_USER)@$(RM_HOST):$(RM_DIR)

# Create a backup of database on local
	@echo "Creating local backup..."
	$(AT)mv $(DB_NAME).sql.bak db-backup/

# Remove work files
	@echo "Removing local files..."
	$(AT)rm -rf $(DB_NAME).sql

# Import the database into remote
	@echo "Importing local database into remote database"
	$(AT)ssh -t $(RM_USER)@$(RM_HOST) "cd $(RM_DIR); php wp-cli.phar db import '$(DB_NAME).sql'; rm -rf $(DB_NAME).sql; exit; bash"

# Recipe: 13.0 - clean
# Parent clean task (runs clean-files and clean-db).
clean: clean-files clean-db

# Recipe: 13.1 - clean-files
# Removes all files and folders related to project.
clean-files:
	@echo
	@echo "$(IMPORTANT)Task | clean-files:$(DEFAULT)" \
	"$(WARNING)Preparing to delete all project files...$(DEFAULT)"

# Confirm deletion (only continue on Y/y)
	$(AT)while [ -z "$$CONFIRM_DEL" ]; do \
		read -r -p "Are you sure you want to delete all folders/files associated with this WordPress install? [y/n]: " \
		CONFIRM_DEL; \
	done; \
	[ $$CONFIRM_DEL = "y" ] || \
	[ $$CONFIRM_DEL = "Y" ] || \
	(echo "Exiting. No files were deleted."; exit 1)

# Delete files
	@echo "Deleting all project files..."
	$(AT)rm -rf wp-config.php wp-content wp-admin wp-includes readme.html \
	license.txt wp-activate.php wp-login.php wp-trackback.php \
	wp-blog-header.php wp-cron.php wp-mail.php wp-comments-post.php \
	wp-links-opml.php wp-settings.php wp-load.php wp-signup.php xmlrpc.php \
	index.php .htaccess latest.tar.gz wordpress wp wp-cli acf-pro.zip .git \
	.gitignore .DS_STORE README.md
	@echo "$(SUCCESS)Success:$(DEFAULT) All project files successfully removed."
	@echo

# Recipe: 13.2 - clean-db
# Drops project database.
clean-db:
	@echo "$(IMPORTANT)Task | clean-db:$(DEFAULT)" \
	"$(WARNING)Preparing to delete database $(DB_NAME)...$(DEFAULT)"

# Confirm database drop (only continue on Y/y)
	$(AT)while [ -z "$$CONFIRM_DROP" ]; do \
		read -r -p "Are you sure you want to delete the database associated with this WordPress install? [y/n]: " \
		CONFIRM_DROP; \
	done; \
	[ $$CONFIRM_DROP = "y" ] || \
	[ $$CONFIRM_DROP = "Y" ] || \
	(echo "Exiting. No database files were deleted."; exit 1)
	@echo "Enter database password for $(DB_NAME) to confirm deletion."

# Drop database (prompt for p/w)
	$(AT)mysql -u$(DB_USER) -p -e"DROP DATABASE IF EXISTS $(DB_NAME)"
	@echo "Deleting database..."
	@echo "$(SUCCESS)Success:$(DEFAULT) $(DB_NAME) database successfully dropped."
	@echo

# Recipe: 14 - help
# Provides instructions on using makefile.
help:
	@echo "$(IMPORTANT)Task | help:$(DEFAULT) Makefile usage..."
	@echo "$(IMPORTANT)> make$(DEFAULT) \t\t\tPerform WordPress project setup."
	@echo "$(IMPORTANT)> make clean$(DEFAULT) \t\tDelete project files/folders"
	@echo "$(IMPORTANT)> make build$(DEFAULT) \t\tRun post project setup to move generated files to root"
	@echo "$(IMPORTANT)> make db-localtoremote$(DEFAULT) Overwite remote database with local Database"
	@echo "$(NOTE)Note: For further details and other make tasks, consult makefile.$(DEFAULT)"
