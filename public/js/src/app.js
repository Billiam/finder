/**
 * @fileOverview App module definition
 */

define(function(require) {
    'use strict';
    require('polyfills/function.bind');
    require('foundation');

    var $ = require('jquery');
    var Map = require('controller/map');
    var Point = require('model/point');
    var Table = require('controller/table');
    /**
     * Initial application setup.
     *
     * @class App
     * @constructor
     */
    var App = function() {

    };

    App.prototype.initFoundation = function() {
        $(document).foundation();
    };

    /**
     * Initializes the application and kicks off loading of prerequisites.
     *
     * @method init
     * @private
     */
    App.prototype.init = function() {
        this.initFoundation();

        var map = new Map('#map', {});
        var table = new Table('.datatable');

        Point.all().done(function(points) {
            map.addPoints(points);
            table.setData(points.toTable());
        });
    };

    return App;
});