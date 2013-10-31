define(function(require) {
    var $ = require('jquery');
    require('datatables.foundation');

    var Table = function(selector, options) {
        var table = null;

        this.init(selector, options);
    };


    Table.prototype.init = function(selector, options) {
        this.table = $(selector).dataTable({
            "aoColumnDefs": [
                {
                    "mRender": function (data, type, row ) {
                        console.log(data);
                        return '<a href="http://reddit.com/u/' + data + '">' + data + '</a>';
                    },
                    "aTargets": [0]
                },
            ]
        });
    };

    Table.prototype.setData = function(data) {
        this.table.fnAddData(data);
    };


    return Table;
});