define(function(require) {
    var $ = require('jquery');
    var CsvParser = require('vendor/parse');
    var Collection = require('model/collection');

    var pointPromise = null;

    /**
     * Thin wrapper around parsed CSV data
     *
     * @param {Object} row
     * @returns {Object}
     * @constructor
     */
    var Point = function(data) {
        this.row = data;
    };

    /**
     * Get values from delegated row
     *
     * @param {String} key
     * @returns {*}
     */
    Point.prototype.get = function(key) {
        return this.row[key];
    };

    Point.prototype.toTable = function() {
        return [
            this.row.name,
            this.row.city,
            this.row.county,
            this.row.state,
            this.row.country
        ]
    };

    /**
     * Parse CSV string to individual point instances
     *
     * @param {String} csv
     * @returns {Array}
     */
    var parseData = function(csv) {
        var points = [];
        var parsed = CsvParser(csv, {});
        var rows = parsed.results.rows;
        for (var i = 0, l = rows.length; i<l; i++) {
            points.push(new Point(rows[i]));
        }
        return points;
    };

    /**
     * Fetch and memoize all points
     *
     * @returns {Deferred.promise}
     */
    Point.all = function() {
        if ( ! pointPromise) {
            var loader = new $.Deferred();
            pointPromise = loader.promise();

            $.get('/.csv', function(data) {
                var points = parseData(data);
                loader.resolve(new Collection(points));
            });
        }

        return pointPromise;
    };

    return Point;
});
