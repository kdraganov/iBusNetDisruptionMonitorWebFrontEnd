/**
 * Created by Konstantin on 14/03/2015.
 */
function poll(version, timeout) {
    setTimeout(function () {
        if ($("#disruptionList") != null) {
            //if (document.URL == "http://localhost:3000/main/index" || document.URL == "http://localhost:3000/") {
            ajaxPollCall(version);
        }
    }, timeout);
}

function ajaxPollCall(lastUpdateTime) {
    new $.ajax('/main/view', {
        method: 'get',
        data: {lastUpdateTime: lastUpdateTime},
        success: function (result) {
            if (result.update) {
                $("#disruptionList").html(result.partial);
            } else {
                $("#lastUpdateTime").html(result.lastUpdateTime)
            }
            poll(result.lastUpdateTime, result.timeout)
            sorttable.makeSortable(document.getElementById("disruptionsTable"));
        }
    });
}

function setSpeed(speed){
    new $.ajax('/main/speed', {
        method: 'get',
        data: {speed: speed}
    });
}