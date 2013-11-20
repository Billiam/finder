require.config({
    paths: {
        'jquery': 'vendor/jquery-1.10.2',
        'leaflet': 'vendor/leaflet/leaflet',
        'leaflet.markercluster': 'vendor/leaflet/leaflet.markercluster',
        'leaflet.hash': 'vendor/leaflet/leaflet-hash',
        'leaflet.minimap': 'vendor/leaflet/leaflet-minimap',
        'jquery.dataTables': 'vendor/datatables/jquery.dataTables.min',
        'dataTables.foundation': 'vendor/datatables/dataTables.foundation',
        'foundation': 'vendor/foundation.min'
    },
    shim: {
        'jquery': { exports: '$' },
        'foundation': {
            exports: '$.fn.foundation',
            deps: ['jquery']
        },
        'leaflet.markercluster': {
            exports: 'L.MarkerClusterGroup',
            deps: ['leaflet']
        },
        'leaflet.minimap': {
            exports: 'L.Control.MiniMap',
            deps: ['leaflet']
        },
        'leaflet.hash': {
            exports: 'L.Hash',
            deps: ['leaflet']
        }
    }
});