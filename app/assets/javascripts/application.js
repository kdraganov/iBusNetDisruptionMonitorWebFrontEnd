// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require foundation
//= require turbolinks
//= require_tree ./global

$(function () {
    $(document).foundation();
});

google.load('visualization', '1', {packages: ['corechart', 'line']});

function details(id) {
    new $.ajax('/disruption/details', {
        method: 'get',
        data: {id: id},
        success: function (result) {
            $('#revealModal').html(result.partial)

            if (!result.error) {
                drawGraph(result.data, result.title, result.hAxisTitle);
            }

            $('#revealModal').foundation('reveal', 'open');
        }
    });
}

function drawGraph(dataArray, title, hAxisTitle) {
    var data = new google.visualization.arrayToDataTable(dataArray);
    var options = {
        title: title,
//            curveType: 'function',
        width: 960,
        height: 600,
        'pointSize': 7,
        lineWidth: 4,
        selectionMode: 'multiple',
        series: {
            0: {color: '#CC0033'},
            1: {color: '#000000'}
        },
        legend: {
            position: 'right',
            alignment: 'center'
        },
        tooltip: {isHtml: true},
        hAxis: {
            title: hAxisTitle,
            slantedText: false
        },
        vAxis: {
            title: 'Lost time (minutes)',
            viewWindowMode: 'explicit',
            viewWindow: {
                max: 80,
                min: 0
            },
            gridlines: {
                count: 8
            }
        },
        colors: ['#a52714', '#097138'],
        crosshair: {
            color: '#000',
            trigger: 'selection'
        }
//            backgroundColor: '#f1f8e9'
//            trendlines: {
//                0: {type: 'exponential', color: '#333', opacity: 1},
//                1: {type: 'linear', color: '#111', opacity: .3}
//            }
    };
    var chart = new google.visualization.LineChart(document.getElementById('lineGraph'));
    chart.draw(data, options);
}