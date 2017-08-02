$(document).ready(function() {
  'use strict';

  // Check for value on load
  $('input').each(function() {
    if ($(this).val().length > 0) {
      $(this).prev('label').addClass('hasVal');
    }
  });

  // Apply the transform effect on focus
  $('input').focus(function() {
    $(this).prev('label').addClass('hasVal active');
  });

  $('textarea').focus(function() {
    $(this).prev('label').addClass('hasVal active');
  });

  // Check if the input has a value
  $('input').blur(function() {
    if ($(this).val().length > 0) {
      $(this).prev('label').removeClass('active');
    } else {
      $(this).prev('label').removeClass('hasVal active');
    }
  });

  $('textarea').blur(function() {
    if ($(this).val().length > 0) {
      $(this).prev('label').removeClass('active');
    } else {
      $(this).prev('label').removeClass('hasVal active');
    }
  });
});