'use strict';

module.exports = function (grunt) {
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-less');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-angular-templates');
  grunt.loadNpmTasks('grunt-protractor-runner');
  grunt.loadNpmTasks('grunt-shell');

  grunt.initConfig({
    coffee: {
      app: {
        options: { join: true },
        files: {
          'build/app.js': 'coffee/**/*.coffee'
        }
      }
    },
    less: {
      dist: {
        files: [{
          expand: true,
          cwd: 'less',
          src: ['*.less', '!.*#.less'],
          dest: 'build/',
          ext: '.css'
        }]
      }
    },
    clean: {
      main: ['build/**/*']
    },
    concat: {
      js: {
        src: [
          "lib/highlightjs/highlight.pack.js",
          "lib/jquery/dist/jquery.min.js",
          "lib/bootstrap/dist/js/bootstrap.min.js",
          "lib/bootstrap/js/alert.js",
          "lib/angular/angular.js",
          "lib/angular-route/angular-route.js",
          "lib/angular-cookies/angular-cookies.js",
          "lib/angular-sanitize/angular-sanitize.js",
          "lib/codemirror/lib/codemirror.js",
          "lib/codemirror/mode/sql/sql.js",
          "lib/codemirror/mode/javascript/javascript.js",
          "lib/angular-ui-codemirror/ui-codemirror.js"
        ],
        dest: 'build/lib.js'
      },
      css: {
        src: ['build/*.css'],
        dest: 'build/app.css'
      }
    },
    watch: {
      main: {
        files: ['coffee/**/*.coffee', 'less/**/*.less'],
        tasks: ['build'],
        options: {
          events: ['changed', 'added'],
          nospawn: true
        }
      }
    }
  });

  grunt.registerTask('build', ['clean', 'coffee', 'less', 'concat']);
};
