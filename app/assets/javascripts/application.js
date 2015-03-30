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

//google.load('visualization', '1', {packages: ['corechart', 'line']});
google.load('visualization', '1', {packages: ['corechart']});

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
        'pointSize': 0,
        lineWidth: 2,
        selectionMode: 'single',
        seriesType: "bars",
        bar: {groupWidth: "90%"},
        series: {
            0: {
                color: '#CC0033',
                type: "bars",
                targetAxisIndex: 0
            },
            1: {
                color: '#000000',
                type: "line",
                targetAxisIndex: 1
            }
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
        vAxes: {
            0: {
                title: 'Lost times (minutes)',
                viewWindowMode: 'explicit',
                viewWindow: {
                    max: 60,
                    min: 0
                },
                gridlines: {
                    count: 12
                }
            },
            1: {
                title: 'Total lost time (minutes)',
                viewWindowMode: 'explicit',
                viewWindow: {
                    max: 120,
                    min: 0
                },
                gridlines: {
                    color: 'none'
                }
            }
        },
        annotations: {
            alwaysOutside: true,
            textStyle: {
                fontSize: 12,
                auraColor: 'none',
                color: '#555'
            },
            boxStyle: {
                stroke: '#ccc',
                strokeWidth: 1,
                gradient: {
                    color1: '#f3e5f5',
                    color2: '#f3e5f5',
                    x1: '0%', y1: '0%',
                    x2: '100%', y2: '100%'
                }
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
    var chart = new google.visualization.ComboChart(document.getElementById('lineGraph'));
    chart.draw(data, options);
}

function addNewComment() {
    new $.ajax('/disruption/addComment', {
        method: 'post',
        data: {id: $('#commentId').val(), comment: $('#commentText').val()},
        success: function (result) {
            if (!result.error) {
                $('#revealModal').html(result.partial);
                window.scrollTo(0, 0);
            } else {
                $('#revealModal').html(result.message);
            }
        }
    });
}

function hideDisruption(id, hidden) {
    if (hidden) {
        if (!confirm("Are you sure you want to show this disruption?")) {
            return false;
        }
    } else {
        if (!confirm("Are you sure you want to hide this disruption?")) {
            return false;
        }
    }
    new $.ajax('/disruption/hide', {
        method: 'post',
        data: {id: id},
        success: function (result) {
            if (!result.error) {
                $("#disruptionList").html(result.partial);
                showAlert("Disruption hidden successfully!", "success");
            } else {
                showAlert(result.errorInfo, "alert");
            }
        }
    });

}

function showAlert(content, type) {
    alert = "<div data-alert class=\"alert-box " + type + " radius text-center\"><strong>" + content + "</strong> <a href=\"#\" class=\"close\">&times;</a> </div>";
    $("#flashDiv").html(alert);
    $(document).foundation('alert', 'reflow');
}