$(document).ready(function(){
  
  var bad_links = [];
  
  $('#add_rule').click(function(){
    $('#rule_div').show();
  });
  
  var add_rule = function(){
    var match_val = $('#rule_field').val();
    if(match_val == ""){ return false; }
    var checked = $('#rule_div').children('input[checked=true]').val();
    var links = $('.link');
    
    $.each(links, function(i){
      var link = $(links[i]);
      var matchy = link.attr('href').match(match_val);
      
      if((checked == "ignore" && matchy) || (checked == "keep" && !matchy)){
        link.removeClass('link');
        var link_href = link.attr('href');
        bad_links[bad_links.length] = link_href;
        link.parent().hide();
      }
    });
  }
  
  $('#rule_add_button').click(add_rule);
  $('#rule_field').keypress(function(e) {
    if (e.keyCode == 13){
      add_rule();
    }
  });
  
  $('.link_bad').live('click', function(){
    var bad_link = $(this).siblings('.link');
    bad_link.removeClass('link');
    var link_href = bad_link.html();
    bad_links[bad_links.length] = link_href;
    $(this).parent().hide();
  });
  
  $('#save_links').click(function(){
    $('.loading_gif').show();
    $('#loading_text').html("saving links...");
    
    var all_links = $('.link');
    var good_links = [];
    
    $.each(all_links, function(i){ 
      good_links[good_links.length] = $(all_links[i]).attr('href'); 
    });
    
    $.ajax({
      type: 'POST',
      url: document.location.pathname + '/save_links',
      data: ({ 
        'bad_links[]': bad_links,
        'good_links[]': good_links
      }),
      success: function(){
        $('.loading_gif').hide();
        alert("Links successfully saved!");
        document.location = '/source_urls'
      },
      error: function(){ 
        $('.loading_gif').hide();
        alert('Error saving links. Try again later.');
      }
    });
  });
  
  $('#crawwwl_link').click(function(){
    $('.loading_gif').show();
    $.ajax({
      dataType: 'json',
      type: 'GET',
      url: document.location.pathname + '/extract_links',
      success: function(json){
        $('#extracted_links').html('');
        $('.loading_gif').hide();
        
        $.each(json, function(i){
          var li = $('<li/>');
          var action_a = $('<a>&nbsp;</a>');
          var internal_a = $('<a></a>');
          
          action_a.addClass('link_bad');
          action_a.addClass('action');
          action_a.attr('title', 'Mark as bad');
          action_a.attr('href', 'javascript:void(0)')
          
          internal_a.attr('href', json[i]);
          internal_a.attr('target', '_blank');
          internal_a.addClass('link');
          internal_a.html(json[i]);
          
          li.append(action_a);
          li.append(internal_a);
          li.appendTo($('#extracted_links'));
          
          $('#extracted_links').show();
          $('#save_links').show();
          $('#add_rule').show();
          $('#crawwwl_link').hide();
        });
      },
      error: function(json){ 
        $('.loading_gif').hide();
        alert('Error gathering links from this URL. Please check the URL and try again later.')
      }
    });
  });
  
  var handle_errors = function(json){
    var obj = JSON.parse(json.responseText);
    $('#source_url_messages').html('');
    $('#link_messages').html('');
    $.each(obj.errors, function(i){
      var li = $('<li/>');
      li.html(obj.errors[i].replace("Url", "URL"));
      $('#source_url_messages').append(li);
      $('#link_messages').append(li);
    });
  };
  
  var suts = $('.source_url_title');
  $.each(suts, function(i){
    var jsut = $(suts[i]);
    jsut.inPlaceEdit('/source_urls/' + jsut.attr('id'));
  });
  
  $('#add_source_url').click(function(){
    $('#url_field').attr('value', 'http://');
    $('#add_source_url_snippet').show();
    $('#add_source_url').hide();
    $('#url_field').focus();
  });
  
  $('.source_url_delete').live('click', function(){
    var the_id = $(this).siblings('.source_url_title').attr('id');
    var sure = confirm("Delete this URL? All associated links will also be deleted.");
    if(!sure){ return false; }
    $.ajax({
      type: 'POST',
      url: '/source_urls/' + the_id,
      data: ({ '_method': 'DELETE' })
    });
    $(this).parent().remove();
  });
  
  var save_source_url = function(){
    var the_url = $('#url_field').val();
    
    $.ajax({
      dataType: 'json',
      type: 'POST',
      url: '/source_urls',
      data: ({
        "source_url[url]": the_url
      }),
      success: function(json){
        var li = $('<li></li>');
        var the_id = json.source_url.id;
        
        $.get('/source_urls/' + the_id + '/index_actions', function(html){
          $('#source_url_list').prepend(li);
          li.prepend(html);
          $('#' + the_id).inPlaceEdit('/source_urls/' + the_id);
        });
        
        $('#source_url_messages').html('');
        $('#add_source_url_snippet').hide();
        $('#add_source_url').show();
      },
      error: function(json){ handle_errors(json); }
    });
  };
  
  var cancel_source_url = function(){
    $('#source_url_messages').html('');
    $('#add_source_url_snippet').hide();
    $('#add_source_url').show();
  };
  
  $('.save_source_url').click(save_source_url);
  $('.cancel_source_url').click(cancel_source_url);

  $('#url_field').keypress(function(e) {
    if (e.keyCode == 13){
      save_source_url();
    } else if (e.keyCode == 27) {
      cancel_source_url();
    }
  });
  
});