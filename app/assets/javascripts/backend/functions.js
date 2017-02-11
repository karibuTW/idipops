var Helper = {
  checkPositiveInteger: function(input) {
    var x;
    if (isNaN(input)) {
      return false;
    }
    x = parseFloat(input);
    return ((x | 0) === x) && (x > 0);
  }
};
$(document).ready(function() {

  /* Add/Subtract point buttons click handler */
  $(document).on('click', '.btn-add-points, .btn-subtract-points', function(e) {
    e.preventDefault();
    var $src = $(this);
    bootbox.prompt("Enter number of points:", function(result) {
      if (Helper.checkPositiveInteger(result)) {
        $.ajax({
          url: $src.data('url'),
          method: 'POST',
          data: { points: parseInt(result) },
          success: function(response) {
            bootbox.alert(response.message);
            // Update view
            if(response.success) {
              $src.closest('td').find('.points').text(response.points);
            }
          }
        });
      } else if (result !== null) {
        bootbox.alert("The number of points is not valid!");
      }
    });
  });
});
