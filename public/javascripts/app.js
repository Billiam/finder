/**
 * @fileOverview App module definition
 */

define(function(require) {
    'use strict';
    require('polyfills/function.bind');
    require('polyfills/array.filter');
    require('foundation');

    var $ = require('jquery');
    var ExternalLinks = require('lib/externalLinks');
    var LocatorController = require('controller/locator');
    var config = window.CONFIG;

    var controllers = {
        locator: LocatorController
    };


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
        ExternalLinks.init();
        this.initFoundation();
        this.initController();
    };

    /**
     * Initialize page-specific controllers
     *
     * @method initController
     */
    App.prototype.initController = function() {
        if ( ! config) {
            return false;
        }
        var controllerName = config.controller;
        var action = config.action;

        if(typeof controllerName === 'string' && controllers[controllerName]) {
            (new controllers[controllerName]()).init(action);
        }
    };

    return App;
});