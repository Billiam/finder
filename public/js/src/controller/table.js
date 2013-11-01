define(function(require) {
    var $ = require('jquery');
    var dataTables = require('jquery.dataTables');
    var foundation = require('dataTables.foundation');
    var eventBus = require('vendor/pubsub');

    var Table = function(selector, options) {
        var table = null;
        var self = this;

        this.bind = function() {
            this.table.eq(0).on('click', '.point-user', function() {
                eventBus.publish('user-locate', $(this).data('name'));
            });
        };

        this.init(selector, options);
    };

    Table.prototype.init = function(selector, options) {
        var $table = $(selector);
        this.table = $table.dataTable({
            "aLengthMenu": [[50, 100, 500, -1], [50, 100, 500, "All"]],
            "iDisplayLength": 50,
            "fnDrawCallback": options.drawCallback.bind($table),
            "aoColumnDefs": [
                {
                    "mRender": function (data, type, row ) {
                        return '<span class="point-user" data-name="' + data + '">' + data + '</span> <a rel="external" href="http://www.reddit.com/u/' + data + '"></a>';
                    },
                    "aTargets": [0]
                }
            ]
        });
        this.bind();
    };

    Table.prototype.setData = function(data) {
        this.table.fnAddData(data);
    };


    return Table;
});