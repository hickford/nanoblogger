$(function(){

var pusher = new Pusher( '<%= Pusher.key %>'); 
var myChannel = pusher.subscribe('posts');

var connected = false; 

pusher.bind('pusher:connection_established', function () {
    connected = true;
    // $('#status').hide().addClass('connected').text('receiving live updates').slideDown();
    $('#header').text('Updates (live)');
});

//  $("#new").validate(); // how to combine with AJAX?

function addPost (post) {
    var author = $('<span>').addClass('author');
    var link = $('<a>').attr('href','/author/'+post.author).text(post.author).appendTo(author);
    var content = $('<span>').addClass('content').text(post.content);
    var timestamp = $('<span>').addClass('timestamp').text('just now');
    var li = $('<li>').append(author).append(content).append(timestamp).prependTo('#posts').hide().slideDown();
}
myChannel.bind('post-create', addPost);

      $('#new').submit( function () {
        var form = $(this),
            url = form.attr('action'),
            method = form.attr('method'),
            data = form.serialize()

        var  author = form.find('[name="author"]'),  content = form.find('[name="content"]')
        
        $.ajax({
          type: method,
          url: url,
          data: data,
          success: function () {   
                $( 'html, body' ).animate( { scrollTop: 0 }, 0 );  
                if (!connected)
                {
                    // display post for folk without pusher. nasty.
                    addPost({'author':author.val(),'content':content.val()});
                }
                content.val(''); 
            }
        });
        return false;
      }); 

});
