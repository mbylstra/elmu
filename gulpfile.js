var gulp = require('gulp');
var elm  = require('gulp-elm');

gulp.task('elm-init', elm.init);

gulp.task('elm', ['elm-init'], function(){
  return gulp.src('src/ReactiveAudio.elm')
    .pipe(elm())
    .pipe(gulp.dest('dist/'));
});

// Rerun the task when a file changes
gulp.task('watch', ['elm'],  function() {
  gulp.watch(['src/*.elm'], ['elm']);
});
