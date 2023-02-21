const axios = require('axios').default

const consumer = async (event) => {
  let body = JSON.parse(event.Records[0].body)

  console.log("이 값을 이용 : ", body);

  const payload = {
  "MessageGroupId" : body.MessageId,
  "MessageAttributeProductId" : body.MessageAttributes.MessageAttributeProductId.Value,
  "MessageAttributeProductCnt" : 3,
  "MessageAttributeFactoryId" : body.MessageAttributes.MessageAttributeFactoryId.Value,
  "MessageAttributeRequester" : '현수빈'
  }
  console.log("paylod 값 : ", payload);

  axios.post('http://project3-factory-api.coz-devops.click/api/manufactures', payload)
  .then(function (response) {
    console.log(response);
  })
  .catch(function (error) {
    console.log(error);
  });

};
module.exports = {
  consumer
};
