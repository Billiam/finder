define(function(require) {
    'use strict';
    var Map = require('controller/map');
    var Point = require('model/point');
    var Table = require('controller/table');
    var ExternalLinks = require('lib/externalLinks');

    /**
     * Initial application setup.
     *
     * @class App
     * @constructor
     */
    var Locator = function() {
    };

    /**
     * Initialize the locator controller
     *
     * @method init
     * @private
     */
    Locator.prototype.init = function() {
        var map = new Map('#map', {});

        var table = new Table('.datatable', {
            drawCallback: function(a) {
                ExternalLinks.init(this);
            }
        });

        Point.all().done(function(points) {
            map.addPoints(points);
            table.setData(points.toTable());
        });
    };

    return Locator;
});