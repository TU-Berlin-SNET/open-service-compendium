'use strict';

module.exports = function(grunt) {

    // load all grunt tasks
    require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks);

    // configurable paths
    var paths = {
        dist: 'public/assets',
        bower: 'vendor/bower_components',
        tmp: 'tmp/grunt_tasks/',
        vendor: 'vendor/',
        src: {
            frontend: 'app/frontend'
        }
    };

    var fileLists = {
        frontend: [
            '<%= paths.bower %>/jquery/dist/jquery.js',
            '<%= paths.bower %>/angular/angular.js',
            '<%= paths.bower %>/angular-animate/angular-animate.js',
            '<%= paths.bower %>/angular-cookies/angular-cookies.js',
            '<%= paths.bower %>/angular-filter/dist/angular-filter.js',
            '<%= paths.bower %>/angular-resource/angular-resource.js',
            '<%= paths.bower %>/angular-ui-router/release/angular-ui-router.js',
            '<%= paths.bower %>/angular-sanitize/angular-sanitize.js',
            '<%= paths.bower %>/angular-touch/angular-touch.js',
            '<%= paths.bower %>/ng-lodash/build/ng-lodash.js',
	        '<%= paths.bower %>/checklist-model/checklist-model.js',

            // Bootstrap components
            '<%= paths.bower %>/bootstrap-sass/assets/javascripts/bootstrap/{button,collapse,dropdown}.js',

            '<%= paths.dist %>/**/*.coffee.js',
            '<%= paths.dist %>/scripts/views.js'
        ]
    };


    try {
        paths.vendor = require('./bower.json').appPath || paths.vendor;
    } catch (e) {}


    //--------------------------------
    // Grunt Config
    //--------------------------------


    grunt.initConfig({
        paths: paths,
        clean: {
            all: {
                options: {
                    force: true
                },
                files: [{
                    dot: true,
                    src: [
                        '.sass-cache',
                        '<%= paths.dist %>'
                    ]
                }]
            },
            frontend: {
                options: {
                    force: true
                },
                files: [{
                    dot: true,
                    src: [
                        '<%= paths.dist %>{,/**}/*.{js,map,coffee}'
                    ]
                }]
            },
            styles: {
                options: {
                    force: true
                },
                files: [{
                    dot: true,
                    src: [
                        '.sass-cache',
                        '<%= paths.dist %>{,/**}/*.{css,scss,sass}',
                        '<%= paths.dist %>{,/**}/*.{png,jpg,gif,svg}'
                    ]
                }]
            }
        },
        jshint: {
            options: {
                jshintrc: '.jshintrc',
                reporter: require('jshint-stylish')
            },
            all: [
                'Gruntfile.js',
                '<%= paths.src.frontend %>/scripts/{,*/}*.js'
            ]
        },
        autoprefixer: {
            options: {
                browsers: ['last 2 versions'],
                map: true
            },
            application_css: {
                expand: true,
                flatten: true,
                src: '<%= paths.dist %>/styles/*.css',
                dest: '<%= paths.dist %>/styles/'
            }
        },
        imagemin: {
            dist: {
                files: [{
                    expand: true,
                    flatten: true,
                    filter: 'isFile',
                    cwd: '<%= paths.src.frontend %>',
                    src: '**/images/*.{png,jpg,jpeg}',
                    dest: '<%= paths.dist %>/images'
                }]
            }
        },
        svgmin: {
            dist: {
                files: [{
                    expand: true,
                    flatten: true,
                    filter: 'isFile',
                    cwd: '<%= paths.src.frontend %>',
                    src: '**/images/*.svg',
                    dest: '<%= paths.dist %>/images'
                }]
            }
        },
        karma: {
            // grunt test defaults to karma:unit
            unit: {
                configFile: 'karma/karma.conf.js'
            },

            // dist for minified code
            dist: {
                configFile: 'karma/karma.conf.dist.js'
            },

            // for CI builds, run `grunt test-ci`
            continuous: {
                configFile: 'karma/karma.conf.dist.js',
                reporters: ['junit'],
                junitReporter: {
                    outputFile: '../test-results/main-app.xml',
                    suite: ''
                }
            }
        },
        ngtemplates: {
            frontend: {
                cwd: '<%= paths.dist %>/views',
                src: '**/*.html',
                dest: '<%= paths.dist %>/scripts/views.js',
                options: {
                    module: 'frontendApp', // use angular.module('frontend')
                    htmlmin: {
                        collapseBooleanAttributes: true,
                        collapseWhitespace: true,
                        removeAttributeQuotes: true,
                        removeComments: true, // only if you don't use comment directives!
                        removeEmptyAttributes: true,
                        removeRedundantAttributes: true,
                        removeScriptTypeAttributes: true,
                        removeStyleLinkTypeAttributes: true
                    }
                }
            }
        },
        coffee: {
            compile: {
                expand: true,
                cwd: '<%= paths.src.frontend %>',
                src: ['scripts/**/*.coffee'],
                dest: '<%= paths.dist %>',
                ext: '.coffee.js'
            }
        },
        sass: {
            dist: {
                options: {
                    sourcemap: 'none',
                    style: 'expanded'
                },
                files: {
                    '<%= paths.dist %>/styles/application.css' : '<%= paths.src.frontend %>/styles/application.scss'
                }
            }
        },
        jade: {
            compile: {
                files: [{
                    expand: true,
                    cwd: '<%= paths.src.frontend %>',
                    src: ['views/**/*.jade'],
                    dest: '<%= paths.dist %>',
                    ext: '.html'
                }]
            }
        },
        concat: {
            options: {
                // define a string to put between each file in the concatenated output
                separator: ';'
            },
            frontend: {
                // the files to concatenate
                src: fileLists.frontend,
                // the location of the resulting JS file
                dest: '<%= paths.dist %>/scripts/application.js'
            }
        },
        uglify: {
            frontend: {
                options: {
                    sourceMap: false,
                    mangle: false // mangle breaks angular conventions
                },
                files: {
                    '<%= paths.dist %>/scripts/application.js': fileLists.frontend
                }
            }
        },
        shell: {
            testRails: {
                options: {
                    stdout: true
                },
                command: 'rake spec; rake cucumber;'
            }
        },
        todos: {
            options: {
                verbose: false
            },
            all: {
                files: [{
                    src: '<%= paths.vendor %>{,/**}/scripts/*.js'
                }, {
                    src: 'app{,/**}/*.rb'
                }, {
                    src: 'features{,/**}/*.feature'
                }]
            }
        },
        copy: {
            fonts: {
                files: [{
                    expand: true,
                    src: ['<%= paths.bower %>/bootstrap-sass/assets/fonts/bootstrap/*'],
                    dest: '<%= paths.dist %>/fonts'
                }]
            }
        }
    });

    //--------------------------------
    // Default Task
    //--------------------------------

    grunt.registerTask('default', ['jshint', 'build', 'combine-js-dist' /*'test:dist'*/]); // basic sanity checks

    //--------------------------------
    // Build Tasks
    //--------------------------------

    grunt.registerTask('build', ['clean:all', 'build-styles', 'build-frontend']); // full dist build

    grunt.registerTask('build-styles', ['clean:styles', 'sass', 'imagemin', 'svgmin', 'autoprefixer:application_css', 'copy']); // css build

    grunt.registerTask('build-frontend', ['clean:frontend', 'jade', 'ngtemplates', 'coffee']); // main-app javascript

    grunt.registerTask('combine-js-dist', ['uglify:frontend']);

    grunt.registerTask('combine-js-dev', ['concat:frontend']);

    //--------------------------------
    // Dev Tasks
    //--------------------------------

    grunt.registerTask('watch-dist', ['build', 'combine-js-dist', 'watch:server-dist']);

    grunt.registerTask('watch-dev', ['build', 'combine-js-dev', 'watch:server-dev']);

    //--------------------------------
    // Test Tasks
    //--------------------------------

    grunt.registerTask('test', ['karma:unit']); // dev test runner

    grunt.registerTask('test-dist', ['build:all', 'karma:dist']); // dev minified source test runner

    grunt.registerTask('test-ci', ['karma:continuous']); // CI post-compile test runner


    //--------------------------------
    // Watch Tasks
    //--------------------------------

    var baseWatchConfig = {
        scss: {
            files: ['<%= paths.src.frontend %>/styles/**/*.scss'],
            tasks: ['sass', 'autoprefixer:application_css'],
            options: {livereload: true, spawn: false}
        },
        images: {
            files: ['<%= paths.vendor %>/**/images/{,**}/*.{png,jpg,gif,svg}'],
            tasks: ['imagemin', 'svgmin'],
            options: {livereload: true, spawn: false}
        },
        coffee: {
            files: ['<%= paths.src.frontend %>/{,**/}*.coffee'],
            tasks: ['coffee', 'combine-js-dist'],
            options: {livereload: true, spawn: false}
        },
        jade: {
            files: ['<%= paths.src.frontend %>/views/**/*.jade'],
            tasks: ['jade', 'ngtemplates', 'combine-js-dist'],
            options: {livereload: true, spawn: false}
        }
    };

    grunt.registerTask('watch:server-dist', function() {
        grunt.config('watch', baseWatchConfig);
        grunt.task.run('watch');
    });

    grunt.registerTask('watch:server-dev', function() {
        // Replace combine-js-dist with combine-js-dev
        // Configuration for watch:test tasks.
        var watchConfig = JSON.parse(JSON.stringify(baseWatchConfig).replace(/combine-js-dist/g, "combine-js-dev"));

        grunt.config('watch', watchConfig);
        grunt.task.run('watch');
    });

};