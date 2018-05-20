/**
* A sample Lambda function ${function_description}
**/
var aws = require("aws-sdk");

exports.handler = function(event, context) {
 
    console.log("REQUEST RECEIVED:\n" + JSON.stringify(event));

    // For Delete requests, immediately send a SUCCESS response.
    if (event.RequestType == "Delete") {
        sendResponse(event, context, "SUCCESS");
        return;
    }

    var responseStatus = "SUCCESS";
    
    // Ensure all expected results are in the response or else Cloudformation errors.
    var responseData = {"alphabet":"undefined", "digits":"undefined", "Error":"", "Timestamp":"undefined"};
    try {
        responseData = doSomethingUsefulAndReturnAResponseObject(event["ResourceProperties"], responseData);
    } catch(err) {
        responseStatus = "FAILED";
        responseData = { "Error": "Reverse Strings failed, " + Date.now()};
    }
    
    sendResponse(event, context, responseStatus, responseData);
}

function doSomethingUsefulAndReturnAResponseObject(event, responseData) {
    // Any strings in the input will be reversed.
    Object.keys(event).forEach(function(key) {
        value = event[key];
        if(typeof value === 'string') {
            responseData[key] = value.split("").reverse().join("");
        }
    });
    responseData["Timestamp"] = Date.now();
    return responseData;
}

// Send response to the pre-signed S3 URL 
function sendResponse(event, context, responseStatus, responseData) {
 
    var responseBody = JSON.stringify({
        Status: responseStatus,
        Reason: "See the details in CloudWatch Log Stream: " + context.logStreamName,
        PhysicalResourceId: context.logStreamName,
        StackId: event.StackId,
        RequestId: event.RequestId,
        LogicalResourceId: event.LogicalResourceId,
        Data: responseData
    });
 
    console.log("RESPONSE BODY:\n", responseBody);
 
    var https = require("https");
    var url = require("url");
 
    var parsedUrl = url.parse(event.ResponseURL);
    var options = {
        hostname: parsedUrl.hostname,
        port: 443,
        path: parsedUrl.path,
        method: "PUT",
        headers: {
            "content-type": "",
            "content-length": responseBody.length
        }
    };
 
    console.log("SENDING RESPONSE...\n");
 
    var request = https.request(options, function(response) {
        console.log("STATUS: " + response.statusCode);
        console.log("HEADERS: " + JSON.stringify(response.headers));
        // Tell AWS Lambda that the function execution is done  
        context.done();
    });
 
    request.on("error", function(error) {
        console.log("sendResponse Error:" + error);
        // Tell AWS Lambda that the function execution is done  
        context.done();
    });
  
    // write data to request body
    request.write(responseBody);
    request.end();
}