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

function ajaxPollCall(version) {
    new $.ajax('/main/view', {
        method: 'get',
        data: {version: version},
        success: function (result) {
            if (result.update) {
                $("#disruptionList").html(result.partial);
            } else {
                $("#lastUpdateTime").html(result.time)
            }
            poll(result.version, result.timeout)

        }
    });
}

function setSpeed(speed){
    new $.ajax('/main/speed', {
        method: 'get',
        data: {speed: speed}
    });
}