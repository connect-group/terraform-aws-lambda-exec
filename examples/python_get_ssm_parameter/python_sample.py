import boto3
import json
import httplib
from urllib2 import build_opener, HTTPHandler, Request
from botocore.exceptions import ClientError

def handler(event,context):

  if event['RequestType'] == "Delete":
    sendResponse(event, context, "SUCCESS", {})
    return

  responseStatus = "SUCCESS"
  responseData = {"value":"", "Error":""}

  if 'ResourceProperties' in event:
    inputs = event['ResourceProperties']
  else:
    raise Exception('ResourceProperties not supplied!')

  if 'default_value' in inputs:
    responseData['value'] = inputs['default_value']

  if 'parameter_name' in inputs:
    try:
      ssm = boto3.client('ssm')
      result = ssm.get_parameter(
          Name = inputs['parameter_name'],
          WithDecryption = False)
      try:
        responseData['value'] = result['Parameter']['Value']
      except KeyError:
        pass
    except ClientError as ce:
      error=ce.response['Error']['Code']
      if error != "ParameterNotFound":
        responseData['Error']=error
  else:
    responseData['Error']="parameter_name not supplied!"
  
  print "result="+responseData['value'] 
  print "Error="+responseData['Error'] 

  sendResponse(event, context, responseStatus, responseData)

  return "OK"

# Send the response to a signed url endpoint.
def sendResponse(event, context, responseStatus, responseData):
  responseBody = json.dumps({
    "Status": responseStatus,
    "Reason": "See the details in CloudWatch Log Stream: " + context.log_stream_name,
    "PhysicalResourceId": context.log_stream_name,
    "StackId": event['StackId'],
    "RequestId": event['RequestId'],
    "LogicalResourceId": event['LogicalResourceId'],
    "Data": responseData
  })

  print('ResponseURL: {}'.format(event['ResponseURL']))
  print('ResponseBody: {}'.format(responseBody))

  opener = build_opener(HTTPHandler)
  request = Request(event['ResponseURL'], data=responseBody)
  request.add_header('Content-Type', '')
  request.add_header('Content-Length', len(responseBody))
  request.get_method = lambda: 'PUT'
  response = opener.open(request)
  print("Status code: {}".format(response.getcode()))
  print("Status message: {}".format(response.msg))

