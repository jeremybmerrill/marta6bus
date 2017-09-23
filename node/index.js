var request = require("request");
var _ = require("underscore");
var parse = require ('csv-parse')
var yaml = require('js-yaml');
var fs   = require('fs');
var path = require('path');
var twilio = require('twilio');
var url = "http://developer.itsmarta.com/BRDRestService/BRDRestService.svc/GetBusByRoute/6";

const secrets = require('./secrets.json');
const endpoints = require ('./dests.json')

function objectify(array) {
    return array.reduce(function(result, currentArray) {
        result[currentArray[0]] = currentArray[1];
        return result;
    }, {});
}

exports.makeMessage = function(error, callback){
  request({
      url: url,
      json: true
  }, function (error, response, body) {

      if (!error && response.statusCode === 200) {
        var southbound_buses = _(body).select(function(bus){ return bus["DIRECTION"] == "Southbound" });
        _(southbound_buses).each(function(bus){
           bus["endpoint"] = endpoints[bus["TRIPID"]];
        });
        var message =  _(southbound_buses).map(function(bus){
          var lateness = bus["ADHERENCE"] == "0" ? "on time" : (bus['ADHERENCE'].to_i < 0 ? (bus["ADHERENCE"] + " min early") : bus["ADHERENCE"] + " min late")
          endpoint = bus["endpoint"].trim().length > 0 ? bus.endpoint.split("STATION")[0].trim() : "unknown endpoint"
          return "Veh #" + bus["VEHICLE"] + " to " + endpoint + ".";
        }).join("\n");
        callback(null, message);
      }else{
        console.log("error! ", response, error)
      }
  })
}

exports.sendSms = function(to, body, fake, callback){
    var account_sid = secrets.twilio.sid
    var auth_token  = secrets.twilio.auth_token
    var from        = secrets.twilio.phone_number
    var client = new twilio(account_sid, auth_token);
    if(!fake){
        client.messages.create({
            body: body,
            to: to,
            from: from 
        })
        .then(function(message){console.log("Sent " + (fake ? "fake " : "") + "message to " + to + " " + message.sid); callback("done")});
    }else{
        console.log("Sent " + (fake ? "fake" : "") + "message to " + to + "; " + body);
    }
}

exports.doTheStuff = function(req, res){
    var to_addr = req.body.From;

    exports.makeMessage(null, function(error, msg){
        if(error){ console.log("error: ", error); return; };
        console.log("sending as SMS to " + to_addr + ": " + msg);
        exports.sendSms(to_addr, msg, false, function(){ console.log("done")}) 
    })

    res.status(200).send('Success: ' + req.body.message);
}


// exports.makeMessage(null, function(error, msg){ 
//     console.log(msg);
//     exports.sendSms("+19197241285", msg, true, function(){ console.log("done")}) 
// })