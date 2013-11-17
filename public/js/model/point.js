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
        this._row = data;
        this._location = undefined;
    };

    /**
     * Get values from delegated row
     *
     * @param {String} key
     * @returns {*}
     */
    Point.prototype.get = function(key) {
        return this._row[key];
    };

    /**
     * Fetch the row location as a string
     *
     * @returns {String}
     */
    Point.prototype.location = function() {
        if (this._location === undefined) {
            this._location = [
                this._row.city,
                this._row.county,
                this._row.state,
                this._row.country
            ].filter(function(i) { return i !== "" }).join(', ');
        }

        return this._location;
    };

    /**
     * Fetch the row data as an array
     *
     * @returns {Array}
     */
    Point.prototype.toTable = function() {
        return [
            this._row.name,
            this._row.city,
            this._row.county,
            this._row.state,
            this._row.country
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
        var parsed = CsvParser.toObjects(csv);
        for (var i = 0, l = parsed.length; i<l; i++) {
            points.push(new Point(parsed[i]));
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
