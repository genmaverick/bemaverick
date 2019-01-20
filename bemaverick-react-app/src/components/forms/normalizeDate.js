const normalizeDate = currDate => {
  let currentDate = currDate;
  let currentLength = currentDate.length;
  let lastNumberEntered = currentDate[currentLength - 1];

  if (currentLength > 10) {
    return currentDate.substring(0, 10);
  }

  // Invalid Characters
  if (!isNumber(lastNumberEntered) && lastNumberEntered !== "/") {
    return currentDate.substring(0, currentLength - 1);
  }

  // Duplicate slashes
  if (currentDate.includes("//")) {
    return currentDate.replace("//", "/");
  }

  // Single slashes
  if (currentDate === "/") {
    return "";
  }

  // Don't allow 00
  currentDate = currentDate.replace("00/", "01/");

  // Limit to two slashes
  if (nthIndex(currentDate, "/", 3) > -1) {
    const index = nthIndex(currentDate, "/", 3);
    const start = currentDate.substring(0, index);
    const end = currentDate.substring(index + 1, currentDate.length);
    console.log(start + " + " + end);
    return start + end;
  }

  // Parse the date
  if (currentLength == 1 && currentDate > 1) {
    return "0" + currentDate;
  } else if (currentLength == 3 && currentDate[2] != "/") {
    if (currentDate[2] <= 3) {
      return currentDate.substring(0, 2) + "/" + currentDate[2];
    } else {
      return currentDate.substring(0, 2) + "/0" + currentDate[2];
    }
  } else if (currentLength > 5 && currentDate[5] != "/") {
    return (
      currentDate.substring(0, 5) +
      "/" +
      currentDate.substring(5, currentDate.length)
    );
  } else if (currentLength == 2 && lastNumberEntered == "/") {
    return "0" + currentDate;
  } else if (currentLength == 5 && lastNumberEntered == "/") {
    return (
      currentDate.substring(0, 3) +
      "0" +
      currentDate.substring(3, currentDate.length)
    );
  }
  return currentDate;
};

export default normalizeDate;

const isNumber = n => {
  return !isNaN(parseFloat(n)) && isFinite(n);
};

function nthIndex(str, pat, n) {
  var L = str.length,
    i = -1;
  while (n-- && i++ < L) {
    i = str.indexOf(pat, i);
    if (i < 0) break;
  }
  return i;
}
