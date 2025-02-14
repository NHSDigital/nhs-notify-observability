exports.handler = (event, context, callback) => {
  const request = event.Records[0].cf.request;

  const match = request.uri.match(/\/(\w+)~([\w-]+)\/?(.*)?/);
    // Breaks the url in to the 'match' object with multiple indexes.
    // The first regex group () matches the URI after the URL for the app domain, eg auth, template, foo
    // The '~' is how we separate the branch structure if specified
    // The second group matches sequences of alphanumerics or '-' characters
    // The third group matches any additional paths in the URI (including any query strings & params)

  if (match) {
    const [_, app, branch, path] = match;
    const amplifyBaseUrl = request.origin.custom.customHeaders["x-amplify-base-url"][0].value
    const targetUrl = `${branch}.${amplifyBaseUrl}`

    request.origin.custom.domainName = targetUrl
    request.headers['host'] = [{ key: 'host', value: targetUrl}];
  }

  return callback(null, request);
};
