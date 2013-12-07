define(function(require) {
    var $ = require('jquery');
    var CsvParser = require('vendor/parse');
    var Collection = require('model/collection');

    var pointPromise = null;

    /**
     * Thin wrapper around parsed CSV data
     *
     * @class Point
     * @constructor
     * @param {Object} row
     * @returns {Object}
     */
    var Point = function(data) {
        this._row = data;
        this._location = undefined;
    };

    /**
     * Get values from delegated row
     *
     * @method get
     * @param {String} key
     * @returns {*}
     */
    Point.prototype.get = function(key) {
        return this._row[key];
    };

    /**
     * Fetch the row location as a string
     *
     * @method location
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
     * @method toTable
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
     * @method parseData
     * @private
     * @param {String} csv
     * @returns {Array}
     */
    var parseData = function(csv) {
        var points = [];
        var parsed = CsvParser.toObjects(csv);
        for (var i = 0, l = parsed.length; i<l; i++) {
            var location = parsed[i];
            var names = location.names.split(',');
            for (var j = 0, k = names.length; j < k; j++) {
                var point = clone(location);
                point.name = names[j];
                points.push(new Point(point));
            }
        }
        return points;
    };

    /**
     * Shallow object clone
     *
     * @method clone
     * @private
     * @param {*} obj
     * @returns {*}
     */
    var clone = function(obj) {
        if (null == obj || "object" != typeof obj) return obj;
        var copy = obj.constructor();
        for (var attr in obj) {
            if (obj.hasOwnProperty(attr)) copy[attr] = obj[attr];
        }
        return copy;
    };

    /**
     * Fetch and memoize all points
     *
     * @method all
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
