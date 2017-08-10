/**
 *
 * Gulp Config FIle
 *
 */

// Set our project and task variables
var config = {

	// project variables
	project: {
		name: 'Brainrider-Workflow',
		textdomain: 'brainrider_workflow',
		namespace: 'br_wf'
	},

	// styles task
	styles: {

		// src order
		src: [
			'scss/style.scss',
			'scss/test.scss',
			'scss/_sprites.scss'
			// Other .scss files...
		]
	},

	// customJs task
	customJs: {

		// src order
		src: [
			'js/custom/custom-example.js'
			// Other custom .js files...
		]
	},

	// vendorJs task
	vendorJs: {

		// src order
		src: [
			'js/vendor/vendor-example.js',
			// Other vendor .js files
		]
	},

	//browserSync task
	browserSync: {

		// proxy
		proxy: 'brainrider-workflow.dev'
	},

	// lint tasks
	lint: {
		js: false,
		scss: false
	}
};

// Export our config options
module.exports = config;
