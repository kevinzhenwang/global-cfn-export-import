const response = require('cfn-response');
const AWS = require('aws-sdk');

exports.handler = (event, context, callback) => {
  console.log("event: ", event);
  console.log("typeof event: ", typeof event);
  const message = JSON.parse(event.Records[0].Sns.Message);
  console.log("message: ", message);
  console.log("typeof message: ", typeof message);
  const { ResourceProperties } = message;
  console.log("ResourceProperties: ", ResourceProperties);
  const fromRegion = ResourceProperties.FromRegion;
  const bucket = '${opt:export-import-bucket}/cfn-exporter-importer/' + fromRegion;
  const key = 'exports-' + fromRegion + '.json';
  let rawExports = [];
  let nextToken = "Start";
  let responseData = { "status": "completed" };

  (async () => {
    try {
      while (nextToken) {
        const data = await retrieveRegionalExport(nextToken, fromRegion);
        rawExports.push(data);
        nextToken = data.NextToken;
      }
      const exports = flattenJson(rawExports);
      await deleteJsonFile(fromRegion, bucket, key);
      await generateJsonFile(JSON.stringify(exports), fromRegion, bucket, key);
      console.log("exports: ", exports);
      return { responseData };
    } catch(err) {
      console.error(err);
      return { err };
    }
  })()
  .then(({ responseData }) => {
    console.log("responseData: ", responseData);
    response.send(message, context, response.SUCCESS, { ...responseData });
  })
  .catch(err => {
    console.error(err);
    response.send(message, context, response.FAILED, { err });
  });
}

async function retrieveRegionalExport(nextToken, region) {
    const cloudformation = new AWS.CloudFormation({ region: region });
    const params = nextToken && nextToken !== 'Start'? { NextToken: nextToken } : {};
    return cloudformation.listExports(params).promise();
}

function flattenJson(rawExports) {
    let exports = [];
    rawExports.forEach((item) => {
        exports.push(item.Exports);
    });   
    return [].concat.apply([], exports);
}

async function deleteJsonFile(region, bucket, key) {
    const s3 = new AWS.S3({region: region});
    const params = {
      Bucket: bucket, 
      Key: key
    };
    return s3.deleteObject(params).promise();
}

async function generateJsonFile(exports, region, bucket, key) {
  const s3 = new AWS.S3({region: region});
  const params = {
    Bucket: bucket,
    Key: key,
    Body: Buffer.from(exports),
    ContentType: "application/json"
  };
  return s3.upload(params).promise();
}
