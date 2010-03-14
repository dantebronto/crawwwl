$(document).ready(function(){
  
  $('#upload_image_link').click(function(){
    $('#image_upload').show();
    $(this).hide();
  });
  
  $('#upload_image_cancel').click(function(){
    $(this).parent().hide();
    $('#upload_image_link').show();
  });
  
  $('.link_delete').live('click', function(){
    var the_id = $(this).parent('.link_title').attr('id');
    var the_id = $(this).parent().siblings('.link_title').attr('id')

    $.ajax({
      type: 'POST',
      url: '/links/' + the_id,
      data: ({ '_method': 'DELETE' })
    });
    $(this).parent().parent().remove();
  });
  
  $('#image_holder img').click(function(){
    $('.loading_gif').show();
    $.ajax({
      type: 'POST',
      url: document.location.pathname + '/assign_image',
      data: ({ 
        '_method': 'PUT',
        'link[image]': $(this).attr('src'),
        'link[description]': $('#link_description').val()
      }),
      error: function(){
        alert('There was an error saving this image');
      },
      success: function(){
        document.location = '/links/next';
      }
    });
  });
  
  $('#add_link').click(function(){
    $('#url_field').attr('value', 'http://');
    $('#add_link_snippet').show();
    $('#add_link').hide();
    $('#url_field').focus();
  });
  
  var handle_errors = function(json){
    var obj = JSON.parse(json.responseText);
    $('#link_messages').html('');
    //$('#add_link').show();
    $.each(obj.errors, function(i){
      var li = $('<li/>');
      li.html(obj.errors[i].replace("Url", "URL"));
      $('#link_messages').append(li);
    });
  };
  
  var save_link = function(){
    var the_url = $('#url_field').val();

    $.ajax({
      dataType: 'json',
      type: 'POST',
      url: '/links',
      data: ({
        "link[url]": the_url,
        "link[status]": 'uncrawwwled'
      }),
      success: function(json){
        if(document.location.search.match(/uncrawwwled/)){
          var li = $('<li></li>');
          var the_id = json.link.id;

          $.get('/links/' + the_id + '/index_actions', function(html){
            $('#link_list').prepend(li);
            li.prepend(html);
            $('#' + the_id).inPlaceEdit('/links/' + the_id);
          });

          $('#link_messages').html('');
          $('#add_link_snippet').html('');
          $('#add_link').show();
        } else {
         document.location = '/links?status=uncrawwwled'
        }
      },
      error: function(json){ handle_errors(json); }
    });
  };
  
  var cancel_link = function(){
    $('#link_messages').html('');
    $('#add_link_snippet').hide();
    $('#add_link').show();
  };
  
  $('.save_link').click(save_link); 
  $('.cancel_link').click(cancel_link);  
  
  var lts = $('.link_title');
  $.each(lts, function(i){
    var lt = $(lts[i]);
    lt.inPlaceEdit('/links/' + lt.attr('id'));
  });

  $('#url_field').keypress(function(e) {
    if (e.keyCode == 13){
      save_link();
    } else if (e.keyCode == 27) {
      cancel_link();
    }
  });


});