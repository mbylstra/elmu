var gulp = require('gulp');
var elm  = require('gulp-elm');
var sass = require('gulp-sass');

gulp.task('elm-init', elm.init);

gulp.task('elm', ['elm-init'], function(){
  return gulp.src('src/ReactiveAudio.elm')
    .pipe(elm())
    .pipe(gulp.dest('dist/'));
});

 
gulp.task('sass', function () {
  gulp.src('./src/scss/**/*.scss')
    .pipe(sass().on('error', sass.logError))
    .pipe(gulp.dest('./dist/css'));
});
 
gulp.task('sass:watch', function () {
  gulp.watch('./src/scss/**/*.scss', ['sass']);
});


// Rerun the task when a file changes
gulp.task('elm:watch', ['elm'],  function() {
  gulp.watch(['src/*.elm'], ['elm']);
});

gulp.task('default', ['elm:watch', 'sass:watch']);
