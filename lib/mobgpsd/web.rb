require "rack"

module Mobgpsd

  class Web

    class << self

    def call(env)
      req = Rack::Request.new(env)
      if req.params['Time'] &&  fix = req.params
        args = [fix["Lon"], fix["Lat"], 0, fix["Time"]]
        nmea = NMEA.new(*args)
        puts "[MobGPSD] Received fix => #{nmea}"

        Mobgpsd.gpsd << nmea
        Mobgpsd.store << args if STORE

        [200, {'Content-Type' => 'text/html'}, []]
      else
        [200, {'Content-Type' => 'text/html'}, layout]
      end
    end

    # This was all from the original py version
    # http://spench.net/drupal/software/iphone-gps
    def layout(content=nil)
      <<LAYOUT
<!--
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
-->
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>MobGPSD Poller</title>
<style type="text/css">
<!--
body {
  background-color: #333;
  color: #aaa;
  font-family: Helvetica;
}
a  { color: #777; text-decoration: none; }
h1 { padding: 0; margin: 0;  color: #666; }
.center { text-align: center; }
.sizeBig { font-size: 24px; }
.label {
  font-size: 0.8em;
  nowrap: nowrap;
  font-weight: bold;
  text-align: right;
}
-->
</style>
<script type="text/javascript">
var iDelay = 2000;
var iTimeoutDelay = 4500;

var bLoop = false;
var idInterval = 0;
var bInRequest = false;
var arrayUpdates = [];
var bSendPending = false;
var timeLast = null;
var bFindingLocation = false;
var idTimeout = 0;
var reqCurrent = null;
var arrayUpdatesOnLine = [];

var vLat = { name: "Lat" };
var vLon = { name: "Lon" };
var vAcc = { name: "Acc" };
var vTime = { name: "Time" };

function urlEncodeDict(dict)
{
  var result = "";
  for (var i = 0; i < dict.length; i++)
  {
    if (i > 0)
      result += "&";
    result += encodeURIComponent(dict[i].name) + "=" + encodeURIComponent(dict[i].value);
  }
  return result;
}

function endRequest(bPurge)
{
  if (idTimeout != 0)
  {
    clearTimeout(idTimeout);
    idTimeout = 0;
  }

  bInRequest = false;
  reqCurrent = null;

  if (bPurge == true)
  {
    arrayUpdatesOnLine = [];
    document.getElementById("idPending").innerHTML = "";
  }
}

function processReqChange(req)
{
  if (req != reqCurrent)
    return;

  //alert(req.status + ": " + req.readyState);

  if (req.status == 200)
  {
    if (req.readyState == 4)  // DONE
    {
      document.getElementById("idResponse").innerHTML = req.statusText;

      endRequest(true);

      if (bSendPending)
        sendUpdates();
    }
    else if (req.readyState != 2) // !HEADERS_RECEIVED
    {
      //alert(req.statusText);
      document.getElementById("idResponse").innerHTML = req.statusText;
    }
  }
  else
  {
    //alert(req.statusText);
    document.getElementById("idResponse").innerHTML = req.statusText;

    endRequest();
  }
}

function updateTimeout()
{
  if (reqCurrent == null)
    return;

  arrayUpdates = arrayUpdatesOnLine.concat(arrayUpdates);

  endRequest(true); // Clear OnLine array

  document.getElementById("idResponse").innerHTML = "Timeout";
  document.getElementById("idPending").innerHTML = arrayUpdates.length + " (<a href='javascript:clearPending();'>clear</a>)";
}

function clearPending()
{
  arrayUpdatesOnLine = [];
  arrayUpdates = [];

  document.getElementById("idPending").innerHTML = "";
}

function foundLocation(position)
{
  document.getElementById("idLat").innerHTML = position.coords.latitude;
  document.getElementById("idLon").innerHTML = position.coords.longitude;
  document.getElementById("idAcc").innerHTML = position.coords.accuracy;

  if (timeLast != position.timestamp)
  {
    timeLast = position.timestamp;
    document.getElementById("idTime").innerHTML = position.timestamp;

    vLat.value = position.coords.latitude;
    vLon.value = position.coords.longitude;
    vAcc.value = position.coords.accuracy;
    vTime.value = position.timestamp;

    var formVars = [vLat, vLon, vAcc, vTime];

    var strForm = urlEncodeDict(formVars);
    //alert(strForm);

    arrayUpdates.push(strForm);
    document.getElementById("idPending").innerHTML = (arrayUpdates.length + arrayUpdatesOnLine.length) + " (<a href='javascript:clearPending();'>clear</a>)";

    sendUpdates();
  }
  else
  {
    document.getElementById("idAcc").innerHTML += "*";
  }

  bFindingLocation = false;

  if (bLoop)
  {
    idInterval = setTimeout("findLocation()", iDelay);
  }
  else
  {
    idInterval = 0;
  }
}

function sendUpdates()
{
  if (bInRequest)
  {
    bSendPending = true;
    return;
  }

  if (arrayUpdates.length == 0)
    return;

  bInRequest = true;

  var req = new XMLHttpRequest();
  var reqURL = window.location.toString();
  req.open("POST", reqURL, true);

  req.onreadystatechange = function() {
      processReqChange(req);
  };

  req.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
  //req.setRequestHeader("Content-Length", strForm.length);
  //req.setRequestHeader("Connection", "close");

  var strForm = "";

  for (var i in arrayUpdates)
  {
    if (i > 0)
      strForm += '&';
    var str = arrayUpdates[i];
    strForm += str;
  }

  arrayUpdatesOnLine = arrayUpdates;
  arrayUpdates = [];

  document.getElementById("idResponse").innerHTML = "...";

  reqCurrent = req;
  req.send(strForm);
  //var g_startTime = (new Date()).valueOf();

  if (idTimeout != 0)
    clearTimeout(idTimeout);

  idTimeout = setTimeout("updateTimeout()", iTimeoutDelay + (arrayUpdatesOnLine.length * 100));
}

function noLocation()
{
  //alert('Could not find location');
  document.getElementById("idAcc").innerHTML = "?";

  if (bLoop)
  {
    idInterval = setTimeout("findLocation()", iDelay);
  }
  else
  {
    idInterval = 0;
  }

  bFindingLocation = false;
}

function findLocation()
{
  if (!bFindingLocation)
  {
    navigator.geolocation.getCurrentPosition(foundLocation, noLocation);
    bFindingLocation = true;
  }
}

function toggleLoop()
{
  bLoop = !bLoop;

  if (bLoop)
  {
    document.getElementById("btnToggle").value = "Disable";

    if (!bInRequest)
      findLocation();
  }
  else
  {
    if (idInterval != 0)
    {
      clearTimeout(idInterval);
      idInterval = 0;
    }

    document.getElementById("btnToggle").value = "Enable";
  }
}
</script>
</head>
<body>
<div style="text-align: right"><a href="http://github.com/nofxx/mobgpsd"><h1> MobGPSD </h1></a></div>
<form id="frm" name="frm" method="post" action="">
  <table width="100%" border="0" cellpadding="0" cellspacing="6" class="sizeBig">
    <tr>
      <td class="label">Lat</td>
      <td width="100%" align="left"><div id="idLat"></div></td>
    </tr>
    <tr>
      <td class="label">Lon</td>
      <td width="100%" align="left"><div id="idLon"></div></td>
    </tr>
    <tr>
      <td class="label">Acc</td>
      <td width="100%" align="left"><div id="idAcc"></div></td>
    </tr>
    <tr>
      <td class="label">Time</td>
      <td width="100%" align="left"><div id="idTime"></div></td>
    </tr>
  <tr>
      <td class="label">Resp</td>
      <td width="100%" align="left"><div id="idResponse"></div></td>
    </tr>
  <tr>
    <td class="label">Pend</td>
    <td align="left"><div id="idPending"></div></td>
  </tr>
  </table>
  <p>
  <!--<input name="toggle" type="checkbox" class="sizeBig" id="toggle" />-->
  <input name="btnToggle" type="button" class="sizeBig" style="width: 195px" id="btnToggle" value="Enable" onClick="toggleLoop();"/>
  <input name="btnFind" type="button" class="sizeBig" id="btnFind" value="Find" onClick="findLocation();"/>
  </p>
</form>
<div class="center" style="font-size: 0.7em">
  Don't forget to disable auto-lock
</div>
<script type="text/javascript">
//toggleLoop(); // Auto-start
</script>
</body>
</html>

LAYOUT
    end
    end

  end

end
