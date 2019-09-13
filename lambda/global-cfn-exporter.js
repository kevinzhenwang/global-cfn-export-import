const AWS = require('aws-sdk');

exports.handler = (event, context, callback) => {
  console.log("event: ", event);
  const message = JSON.parse(event.Records[0].Sns.Message);
  console.log("message: ", message);
  const { ResourceProperties } = message;
  console.log("ResourceProperties: ", ResourceProperties);
  const { fromRegion, exportName, exportValue } = ResourceProperties;
  const bucket = 'youruniqueprefix-export-import-bucket';
  const exportJsonKey = 'exports-' + fromRegion + '.json';
  let responseData = { "status": "completed" };

  (async () => {
    try {
      let json = null;
      const isKeyExist = await isBucketKeyExist(fromRegion, bucket, exportJsonKey);  
      console.log('isBucketKeyExist: ', isKeyExist);
      if (isKeyExist) {
        const getObject = await getExportObject(fromRegion, bucket, exportJsonKey);
        json = JSON.parse(getObject.Body.toString());
        json = modifyExportObject(json, exportName, exportValue);
      } else {
        json = { [exportName]: exportValue };
      }

      console.log('JSON for exporting: ', json);
      await putExportObject(fromRegion, bucket, exportJsonKey, json);

      return { responseData };
    } catch(err) {
      console.error('err: ', err);
      return { err };      
    }

  })()
  .then(({ responseData }) => {
    console.log("responseData: ", responseData);
  })
  .catch(err => {
    console.error(err);
  });
}

async function isBucketKeyExist(region, bucket, key) {
  let isExist = false;
  const allExportObjects = await listExportObjects(region, bucket);
  console.log('allExportObjects: ', allExportObjects);

  if (allExportObjects && allExportObjects.Contents && allExportObjects.Contents.length > 0) {
      isExist = allExportObjects.Contents.some((object) => object.Key === key);
  }
  
  return isExist;
}

async function listExportObjects(region, bucket) {
  console.log('list objects of bucket  ', bucket);
  const s3 = new AWS.S3({region: region, signatureVersion: 'v2'});
  const params = {
    Bucket: bucket, 
    MaxKeys: 100
  };
  return s3.listObjects(params).promise();
} 

async function getExportObject(region, bucket, key) {
  const s3 = new AWS.S3({region: region});
  const params = {
    Bucket: bucket,
    Key: key
  };
  return s3.getObject(params).promise();  
}

async function putExportObject(region, bucket, key, json) {
  const s3 = new AWS.S3({region: region});
  const params = {
    ServerSideEncryption: "AES256",
    Bucket: bucket,
    Key: key,
    Body: JSON.stringify(json, null, 2),
    ContentType: "application/json"
  };
  await s3.putObject(params).promise();  
}

function modifyExportObject(json, name, value) {
  return Object.assign(json, { [name]: value });
}
