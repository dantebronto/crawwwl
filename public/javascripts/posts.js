var thumbnail_width = function(){
  if($('#post_thumbnail_dimension').length){
    return $('#post_thumbnail_dimension').val().split("x")[0];
  }
};

var thumbnail_height = function(){
  if($('#post_thumbnail_dimension').length){
    return $('#post_thumbnail_dimension').val().split("x")[1];
  }
};

var show_preview = function(coords) { // image crop preview
	var rx = thumbnail_width() / coords.w;
	var ry = thumbnail_height() / coords.h;
	
	$('#thumbnail_x1').val(coords.x); // update form with resize coords
	$('#thumbnail_y1').val(coords.y);
	$('#thumbnail_w').val(coords.w);
	$('#thumbnail_h').val(coords.h);
	
	$('#thumbnail_preview').css({
		width: Math.round(rx * $('#jcrop_target').width()) + 'px',
		height: Math.round(ry * $('#jcrop_target').height()) + 'px',
		marginLeft: '-' + Math.round(rx * coords.x) + 'px',
		marginTop: '-' + Math.round(ry * coords.y) + 'px'
	});
};

// return array of id's of links in the post in order
var post_order = function(){
  var thumbs = $('.post_thumb');
  var ara = new Array();
  $.map(thumbs, function(e){ 
    ara[ara.length] = $(e).attr('id');
  });
  return ara;
};

$(document).ready(function(){  
  
  // index page stuff
  
  var pts = $('.post_title');
  $.each(pts, function(i){
    var pt = $(pts[i]);
    pt.inPlaceEdit('/posts/' + pt.attr('id') + '/change_name');
  });
  
  $('.post_delete').click(function(){
    var sure = confirm("Delete this post?");
    if(!sure){ return false; }
    
    var the_id = $(this).parent('.post_title').attr('id');
    var the_id = $(this).parent().siblings('.post_title').attr('id')

    $.ajax({
      type: 'POST',
      url: '/posts/' + the_id,
      data: ({ '_method': 'DELETE' })
    });
    $(this).parent().parent().remove();
  });
  
  // builder stuff
    
  var post_columns = function(){
    return Number($('#post_columns').val());
  };

  var previous_post_columns = post_columns();

  var adjust_all_thumbs = function(){
    $.map($('.post_thumb'), function(e){
      var current_image = $('img', e);
      var current_source = current_image.attr('src');

      var size_name = $('#post_thumbnail_dimension option:selected').text().replace(/\ /, '_');
      var replacement_text = current_source.replace(/\/extra_small\/|\/small\/|\/medium\/|\/large\/|\/extra_large\/|\/huge\//, '/' + size_name + '/');
      current_image.attr('src', replacement_text);
      $(e).css('width', thumbnail_width() + "px");
      $(e).css('height', thumbnail_height() + "px");
    });
    var post_holder_width = post_columns() * (Number(thumbnail_width()) + 12);
    $('#post_holder').css('width', post_holder_width + "px");
  };
  
  $('form').keypress(function(e) { // disable default enter key
    if (e.keyCode == 13) { return false; }
  });
  
  $('#post_total_links, #post_columns').keypress(function(e){  // make enter focus these fields
    if(e.keyCode == 13){ $(this).blur().focus(); }
  });  
  
  var active_link_id;
  
  var total_links = $('.post_thumb').length;
  $('#post_total_links').val(total_links);
  
  $('.labeled_form').submit(function(){
    $('#post_link_order').val(post_order());
  });
  
  $('#post_holder').sortable();
  
  $('.post_thumb').live('mousedown', function(){ // thumbnail clicked
    $('#recrop_holder').hide();
    $('.post_thumb').removeClass('selected');
    $(this).addClass('selected');
    
    active_link_id = $(this).attr('id');
    $('#link_id').val(active_link_id);
    
    $.get('/links/' + active_link_id + '/details', function(res){   
      $('#link_details').html(res);
      $('#link_description').inPlaceEdit('/links/' + active_link_id + '/update_description');
    });
  });
  
  $('#remove_link').live('click', function(){
    if(Number(total_links) > 1){
      $('#' + active_link_id).remove();
      total_links -= 1;
      $('#post_total_links').val(total_links); 
    }
  });
  
  $('#replace_link').live('click', function(){
    var parent = $('#replace_link').parent();
    parent.html("<span>...</span>");
    
    $.get('/posts/more/1', {post_order: post_order}, function(res){
      var elem = $(res);
      elem.insertAfter($('#' + active_link_id));
      $('#' + active_link_id).remove();
      active_link_id = elem.attr('id');
      elem.mousedown(); // simulate activation click
      $('#' + active_link_id).addClass('selected');
      total_links = $('.post_thumb').length;
      $('#post_total_links').val(total_links);
      elem.addClass('selected');
      
      adjust_all_thumbs();
    });
  });
  
  $('#mark_as_bad').live('click', function(){
    var parent = $('#mark_as_bad').parent();
    parent.html("<span>...</span>");
    $.ajax({
      type: 'POST',
      url: '/links/' + active_link_id + '/mark_as_bad',
      data: ({ '_method': 'PUT' }),
      success: function(){
        parent.html("<span>Link status updated</span>");
      }
    });
  });
  
  $('#post_columns').bind('blur', function(){
    if(post_columns() > 0) {
      var post_holder_width = post_columns() * (Number(thumbnail_width()) + 12);
      $('#post_holder').css('width', post_holder_width + "px");
    } else {
      $(this).val(previous_post_columns);
    }
  });
  
  $('#post_total_links').bind('blur', function(){
    var new_total = Number($(this).val());
    if(new_total > 0){
      total_links = $('.post_thumb').length;
      
      if( new_total < total_links ){ // links removed
        var diff = total_links - new_total;
        for(var i=0; i<diff; i++){
          $($('.post_thumb')[$('.post_thumb').length-1]).remove();
        }
        total_links = new_total;
        
      } else { // links added
        var diff = new_total - total_links;
        $.get('/posts/more/' + diff, {post_order: post_order}, function(res){
          $('#post_holder').append(res);
          total_links = $('.post_thumb').length;
          $('#post_total_links').val(total_links);
          adjust_all_thumbs();
        });
      }
    } else {
      $(this).val(total_links);
    }
  });
  
  $('#post_thumbnail_dimension').bind('change', function(){
    $('.linky').hide();
    adjust_all_thumbs();
  });
  
  $('#upload_new_image').live('click', function(){
    $('.linky').hide();
    $('#crop_image_submit_buttons').show();
    $('#image_upload').show();
  });
  
  $('#upload_image_cancel').click(function(){
    $('.linky').hide();
  });
  
  $('#recrop_thumbnail').live('click', function(){
    $('.linky').hide();
    $('#recrop_holder').html($('#temp_recrop_holder').html()).show();
    $('#jcrop_target').Jcrop({
  		onChange: show_preview,
  		aspectRatio: 1.2
  	});
  	$('#thumbnail_mask').css({
  	  overflow: 'hidden',
  	  width: thumbnail_width() + 'px',
  	  height: thumbnail_height() + 'px',
  	  border: 'thin solid #333'
  	});
  });
  
  $('#cancel_recrop').live('click', function(){
    $('.linky').hide();
  });
  
  $('#post_start_over').click(function(){
    var sure = confirm("Reshuffle images and create a new post?");
    if(sure) document.location = "/posts/new";
  });
  
  $('#post_add_link').click(function(){
    $('.linky').hide();
    $('#add_link_submit_buttons').show();
    $('#link_form_stuff').show();
    $('#image_upload').show();
  });
  
  $('#add_link_cancel').click(function(){
    $('.linky').hide();
  });
  
  if($('.errorExplanation').length){ // TODO: fix this on backend, too lazy right now
    $('.errorExplanation ul li').each(function(){
      $(this).text( $(this).text().replace(/Url/, "URL") );
    });
  }
  
  adjust_all_thumbs();
  
});