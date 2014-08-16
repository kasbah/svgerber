# gulpfile
# front end deps
jeet       = require 'jeet'
rupture    = require 'rupture'
# dependencies
browserify = require 'browserify'
watchify   = require 'watchify'
source     = require 'vinyl-source-stream'
path       = require 'path'
# gulp and plugins
gulp       = require 'gulp'
gutil      = require 'gulp-util'
streamify  = require 'gulp-streamify'
stylus     = require 'gulp-stylus'
prefix     = require 'gulp-autoprefixer'
minifycss  = require 'gulp-minify-css'
jade       = require 'gulp-jade'
uglify     = require 'gulp-uglifyjs'
rimraf     = require 'gulp-rimraf'
deploy     = require 'gulp-gh-pages'
ignore     = require 'gulp-ignore'
concat     = require 'gulp-concat'
webserver  = require 'gulp-webserver'

# deploy location
DEPLOY = './public'

# app files
SCRIPT   = './coffee/app.coffee'
TEMPLATE = './jade/index.jade'
STYLE    = './stylus/app.styl'

# vendor files
VENDOR_JS = [
  './bower_components/jquery/dist/jquery.min.js'
]
VENDOR_CSS = [
  './bower_components/octicons/octicons/octicons.css'
]
VENDOR_ICON = [
  './bower_components/octicons/octicons/octicons.eot'
  './bower_components/octicons/octicons/octicons.ttf'
  './bower_components/octicons/octicons/octicons.woff'
  './bower_components/octicons/octicons/octicons.svg'
]

# arguments (checks for production build)
argv = require('minimist') process.argv.slice(2), {
  default: { p: false }
  alias: { p: 'production' }
}

# bundle vendor files with concat if necessary and copy them to deploy folder
gulp.task 'vendorCSS', ->
  gulp.src VENDOR_CSS
    .pipe concat 'vendor.css'
    .pipe gulp.dest DEPLOY
gulp.task 'vendorJS', ->
  gulp.src VENDOR_JS
    .pipe concat 'vendor.js'
    .pipe gulp.dest DEPLOY
gulp.task 'vendorIcon', ->
  gulp.src VENDOR_ICON
    .pipe gulp.dest DEPLOY
gulp.task 'vendor', [ 'vendorCSS', 'vendorJS', 'vendorIcon' ]

# clean out the deploy folder
gulp.task 'clean', ->
  gulp.src "#{DEPLOY}/*"
    .pipe rimraf()

# compile stylus
gulp.task 'style', ->
  gulp.src STYLE
    .pipe stylus( { use: [ jeet(), rupture() ] } ).on 'error', gutil.log
    .pipe prefix 'last 2 versions', '> 5%'
    .pipe if argv.p then minifycss() else gutil.noop()
    .pipe gulp.dest DEPLOY

# compile jade
gulp.task 'template', ->
  gulp.src TEMPLATE
    .pipe jade().on 'error', gutil.log
    .pipe gulp.dest DEPLOY

# compile and bundle coffee with browserify
gulp.task 'script', ->
  browserify SCRIPT
    .bundle().on 'error', gutil.log
    .pipe source path.basename gutil.replaceExtension SCRIPT, '.js'
    # minify if production build
    .pipe if argv.p then streamify uglify {
      preamble: '/* view source at github.com/mcous/svgerber */'
      compress: { drop_console: true }
      mangle: true
    } else gutil.noop()
    .pipe gulp.dest DEPLOY

# default task build everything
gulp.task 'build', [ 'vendor', 'style', 'template', 'script' ]

# watch files with coffee files with watchify and others with gulp.watch
gulp.task 'watch', ->
  bundler = watchify browserify SCRIPT, {
    cache: {}
    packageCache: {}
    fullPaths: {}
  }
  rebundle = ->
    bundler.bundle()
      .on 'error', (e) ->
        gutil.log 'browserify error', e
      .pipe source path.basename gutil.replaceExtension SCRIPT, '.js'
      .pipe gulp.dest DEPLOY
  bundler.on 'update', rebundle
  bundler.on 'log', (msg) -> gutil.log "bundle: #{msg}"

  # watch stylus
  gulp.watch './stylus/*.styl', ['style']
  # watch jade
  gulp.watch './jade/*.jade', ['template']
  # bundle coffee
  rebundle()

# deploy to gh-pages
gulp.task 'deploy', ['build'], ->
  gulp.src DEPLOY
    .pipe deploy {
      branch: 'gh-pages'
      push: argv.p
    }

# dev server is default task
gulp.task 'default', [ 'build', 'watch' ], ->
  gulp.src DEPLOY
    .pipe webserver {
      livereload: true
      open: true
    }