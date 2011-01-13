$(function(){

var pusher = new Pusher( '<%= Pusher.key %>'); 

var myChannel = pusher.subscribe('posts');

var connected = false; 

function addPost (post) {
    var author = $('<span>').addClass('author');
    var link = $('<a>').attr('href','/author/'+post.author).text(post.author).appendTo(author);
    var content = $('<span>').addClass('content').text(post.content);
    var timestamp = $('<span>').addClass('timestamp').text('just now');
    var li = $('<li>').append(author).append(content).append(timestamp).prependTo('#posts').hide().slideDown();
}

      pusher.bind('pusher:connection_established', function () {
            connected = true;
            $('#status').addClass('connected').find('span').text('receiving live updates');
        $('#status').fadeIn().show();

      });

myChannel.bind('post-create', addPost);

    /* add validation? */

      if (connected) {

      $('#new').submit( function () {
        var form = $(this),
            url = form.attr('action'),
            method = form.attr('method'),
            data = form.serialize(),
            textarea = form.find('textarea');
        
        $.ajax({
          type: method,
          url: url,
          data: data,
          success: function () {textarea.val(''); $( 'html, body' ).animate( { scrollTop: 0 }, 0 );            }
        });
        return false;
      }); 
    }

    /* if javascript on but pusher failed, nothing happens. refresh the page or add post by hand? */ 

});
