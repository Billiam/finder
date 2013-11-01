define(function(define) {
    var $ = require('jquery');

    return {
        init: function(node) {
            if ( ! node) {
                node = document;
            }

            $('a[rel=external]', node).addClass('external-link').attr('target', '_blank');
        }
    }
});