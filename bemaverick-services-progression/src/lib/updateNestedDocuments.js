const updateNestedDocuments = async ({
  Model, contentType, contentId, data,
}) => {
  // console.log('updateNestedDocuments');
  // console.log('updateNestedDocuments.contentType', contentType);
  // console.log('updateNestedDocuments.contentId', contentId);
  // console.log('updateNestedDocuments.data', data);
  const nestedDocuments = {
    user: ['response.user', 'challenge.user', 'response.challenge.user'],
    challenge: ['response.challenge'],
  };
  const primaryIds = {
    user: 'userId',
    challenge: 'challengeId',
    response: 'responseId',
  };

  // Only process nested documents
  if (!nestedDocuments[contentType]) {
    return null;
  }

  const locations = nestedDocuments[contentType];
  const updates = locations.map(async (location) => {
    const filter = {};
    filter[`${location}.${primaryIds[contentType]}`] = contentId;
    const operations = { $set: {} };
    operations.$set[`${location}`] = data;
    console.log('updateNestedDocuments.filter', filter);
    console.log('updateNestedDocuments.operations', operations);
    return Model.updateMany(filter, operations);
  });

  const updateResponses = await Promise.all(updates);
  console.log('updateNestedDocuments.updateResponses', updateResponses);

  return updateResponses;
};

module.exports = updateNestedDocuments;
