$.fn.inPlaceEdit = function(url){
  var field = $(this);

  $(this).editInPlace({
    url: url,
    bg_over: '#333',
    params: "_method=put&authenticity_token=" + encodeURIComponent(rails_authenticity_token),
    error: function(json){ handle_errors(json); },
    success: function(){ 
      $('#source_url_messages').html('');
      $('#link_messages').html('');
      field.siblings('.source_url_check').attr('href', field.html());
      field.siblings('.link_check').attr('href', field.html());
    }
  });
  
};

$(document).ready(function(){
  var attempts = 0;
  
  function poll_for_publish(path) {
    attempts += 1;
    $.ajax({
      type: 'GET',
      url: path,
      success: function(){
        $('.loading_gif').hide();
        $('#archive_link').parent().show();
      },
      error: function(){
        // not ready yet...
        if(attempts > 20){
          $('.loading_gif').hide();
          $('#publish_post').parent().show();
          attempts = 0;
          alert('There was an error creating your archive. Please try again later.');
        } else {
          setTimeout(function(){ 
            poll_for_publish(path); 
          }, 1000);  
        }
      }
    });
  }
  
  $('#publish_post').click(function(){
    var sure = confirm('Create an archive of this post?');
    if(!sure){ return false; }
    
    $('#publish_post').parent().hide();
    $('.loading_gif').show();
    
    $.post(document.location.pathname + '/publish', function(){
        poll_for_publish(document.location.pathname + '/poll_for_publish')
    });
  });
});