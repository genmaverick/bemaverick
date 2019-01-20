// countdown refreshes every 30 seconds
var launchDate = new Date("April 28, 2018 09:00:00").getTime();

function setLaunchCount() {
    if (!document.getElementById("monthNum")) {
        return;
    }

    // handle numbers
    var now = new Date().getTime();
    var distance = launchDate - now;

    var monthNum = 0;
    var dayNum = Math.floor(distance / (1000 * 60 * 60 * 24));
    var hourNum = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));

    if (dayNum > 31) {
        monthNum = Math.floor(dayNum / 31);
        dayNum = dayNum - 31;
    }

    // add 0s to numbers
    if (monthNum < 10) {
        monthNum = "0" + monthNum.toString();
    }
    if (dayNum < 10) {
        dayNum = "0" + dayNum.toString();
    }
    if (hourNum < 10) {
        hourNum = "0" + hourNum.toString();
    }

    // handle text
    var monthText = "Months";
    var dayText = "Days";
    var hourText = "Hours";

    if (monthNum === "01") {
        monthText = "Month";
    }
    if (dayNum === "01") {
        dayText = "Day";
    }
    if (hourNum === "01") {
        hourText = "Hour";
    }

    if (document.getElementById("monthNum")) {
        document.getElementById("monthNum").innerHTML = monthNum;
        document.getElementById("monthText").innerHTML = monthText;
        document.getElementById("dayNum").innerHTML = dayNum;
        document.getElementById("dayText").innerHTML = dayText;
        document.getElementById("hourNum").innerHTML = hourNum;
        document.getElementById("hourText").innerHTML = hourText;
    }

    // If the count down is finished, write some text
    if (distance < 0 && document.getElementById("demo") && x) {
        clearInterval(x);
        document.getElementById("demo").innerHTML = "EXPIRED";
    }
}

setTimeout(setLaunchCount, 800);
setInterval(setLaunchCount, 30000);
