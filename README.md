# Brainrider WordPress Workflow

WordPress automated workflow and setup. Developed as part of the Brainrider web team to allow for accelerated start up of web projects.

## Getting Started

Out of the box, this workflow is designed to work with the [Brainrider boilerplate](https://github.com/NathanMHouse/brainrider-boilerplate).

Once the initial project setup is complete, all development should occur within the src folder with dist files being generated at the top level via gulp.

### Prerequisites

```
npm (see package.json for specific dependencies)
bower (see bower.json for specific dependencies)
Advanced Custom Fields Pro plugin
MAMP PRO
```

### Installing

Copy or clone the repo to your project directory. While you're at it remove the remote URL:

```
cd project-directory/
git clone https://github.com/NathanMHouse/brainrider-workflow.git ./
git remote rm origin
```

Set up a local development host (using MAMP PRO or manually)

Next, adjust the defaults in the associated configuration files. These include:

* gulp-config.js: contains configuration settings specific to gulp workflow (e.g. JS file concatonation order, local proxy URL etc.)
* make-config.yml: contains configuration settings specific to intial project setup (e.g. WordPress settings, repo credentials etc.)
* wp-cli.yml: contains configuration settings specific to WP-CLI (e.g. additional wp-config options, allows for creations of .htaccess etc.)

Once these files have been updated to your project-specific settings, run the default make task:

```
make
```
The setup process will take several minutes with occasional prompts requiring feedback. Once complete, you're good to go!

### Other Commands
In addition to basic project setup, a number of other useful commands exist:

* make clean: deletes all project files and prompts removal of local DB
* make build: runs post project setup to move generated files to root
* make db-localtoremote: overwrites remote DB with local DB (in-progress/currently disabled)
* make help: provides list of available make commands

## Built With

* [Underscores](https://github.com/Automattic/underscores.me)
* [Brainrider Boilerplate](https://github.com/NathanMHouse/brainrider-boilerplate)
* [Brainrider Resource Centre Plugin](https://github.com/NathanMHouse/brainrider-resource-centre-plugin)
* [WordPress-VIP Coding Standards](https://github.com/Automattic/VIP-Coding-Standards)
* [PHPCS](https://github.com/squizlabs/PHP_CodeSniffer)
* [Advanced Custom Fields Plugin](https://www.advancedcustomfields.com/)
* [iThemes Security Plugin](https://ithemes.com/security/)
* [Gulp](https://gulpjs.com/)

## Future Development
* Local to remote and remote to local DB sync
* Compatability fixes
* Automated vhost setup
* More!

## Author

* **Nathan M. House** - [NathanMHouse](https://github.com/NathanMHouse)

## License

This project is licensed under the GNU V.2 license - see the LICENSE file for details.

## Acknowledgments

* [Zell Liew](https://zellwk.com/) - workflow automation 
* Catia Rocha - build strategy