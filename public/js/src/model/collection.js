define(function(require) {
    var Collection = function(data) {
        var items = [];
        var index = 0;

        this.init(data);
    };

    Collection.prototype = {
        init: function(data) {
            this.items = data;
        },
        first: function() {
            this.reset();
            return this.next();
        },
        next: function() {
            return this.items[this.index++];
        },
        hasNext: function() {
            return this.index <= this.items.length;
        },
        reset: function() {
            this.index = 0;
        },
        length: function() {
            return this.items.length;
        },
        each: function(callback) {
            for (var i = 0, l = this.length(); i < l; i++) {
                callback(this.items[i]);
            }
        },
        map: function(callback) {
            var results = [];
            this.each(function(item) {
                results.push(callback(item));
            });
            return results;
        },
        push: function(item) {
            this.items.push(item);
        },
        toTable: function() {
            return this.map(function(item) {
                return item.toTable();
            });
        }
    };

    return Collection;
});