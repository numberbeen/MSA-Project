const axios = require('axios').default

const consumer = async (event) => {
  for (const records of event.Records) {
    const body = JSON.parse(event.Records[0].body)
    
    console.log("이 값을 이용 : ", body);

  const payload = {
    "MessageGroupId" : "stock-arrival-group",
    "MessageAttributeProductId" : body.MessageAttributes.MessageAttributeProductId.Value,
    "MessageAttributeProductCnt" : 3,
    "MessageAttributeFactoryId" : body.MessageAttributes.MessageAttributeFactoryId.Value,
    "MessageAttributeRequester" : "현수빈",
    "CallbackUrl" : "https://0ayufaryi7.execute-api.ap-northeast-2.amazonaws.com/product/donut"
   }
  console.log("paylod 값 : ", payload);

  await axios.post('http://project3-factory-api.coz-devops.click/api/manufactures', payload)
  .then(function (response) {
    console.log(response);
  })
  .catch(function (error) {
    console.log(error);
  });
 };
}

module.exports = {
  consumer
};
