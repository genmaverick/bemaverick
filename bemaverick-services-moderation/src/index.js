module.exports.main = (event, context, callback) => {
  const response = {
    statusCode: 200,
    body: JSON.stringify({
      message: 'Moderation Service!!!',
      input: event,
    }),
  };
  callback(null, response);
};
