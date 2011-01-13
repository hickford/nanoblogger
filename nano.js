var pusher = new Pusher('3e0eaf103f5b0f5ef114');
var myChannel = pusher.subscribe('posts');

myChannel.bind('post-create', function(post) {
    var author = $('<span>').addClass('author');
    var link = $('<a>').attr('href','/author/'+post.author).text(post.author).appendTo(author);
    var content = $('<span>').addClass('content').text(post.content);
    var timestamp = $('<span>').addClass('timestamp').text('just now');
    var post = $('<li>').append(author).append(content).append(timestamp).prependTo('#posts').hide().slideDown();
});

/*
      $('#new').submit(function () {
        var form = $(this),
            url = form.attr('action'),
            method = form.attr('method'),
            data = form.serialize(),
            body = form.find('input#body');
        
        $.ajax({
          type: method,
          url: url,
          data: data,
          success: function () {body.val('')}
        });
        return false;
      }); */
