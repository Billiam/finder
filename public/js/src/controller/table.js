define(function(require) {
    var $ = require('jquery');
    var dataTables = require('jquery.dataTables');
    var foundation = require('dataTables.foundation');

    var Table = function(selector, options) {
        var table = null;

        this.init(selector, options);
    };


    Table.prototype.init = function(selector, options) {
        this.table = $(selector).dataTable({
            "aLengthMenu": [[10, 100, 500, -1], [10, 100, 500, "All"]],
            "aoColumnDefs": [
                {
                    "mRender": function (data, type, row ) {
                        return '<a href="http://reddit.com/u/' + data + '">' + data + '</a>';
                    },
                    "aTargets": [0]
                }
            ]
        });
    };

    Table.prototype.setData = function(data) {
        this.table.fnAddData(data);
    };


    return Table;
});