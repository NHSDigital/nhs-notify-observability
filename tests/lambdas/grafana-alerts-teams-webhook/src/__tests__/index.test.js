const lambdaHandler = require('../index.js');

describe('Lambda@Edge URI Origin Rewriting', () => {
    let callback, context, event;

    beforeEach(() => {
        callback = jest.fn();
        context = {};
        event = {
          Records: [
            {
              cf: {
                request: {
                  headers: {
                    host: [
                      {
                        key: "host",
                        value: "main.example.com"
                      }
                    ]
                  },
                  uri: '',
                  origin: {
                    custom: {
                      customHeaders: {
                        "x-amplify-base-url": [
                          {
                            value: "example.com"
                          }
                        ]
                      }
                    }
                  }
                }
              }
            }
          ]
        };
    });

    test('Request should be modified if the URI matches the pattern', () => {
      event.Records[0].cf.request.uri = "/auth~feat-branch/some/path";
      lambdaHandler.handler(event, context, callback);

      expect(callback).toHaveBeenCalledWith(null, expect.objectContaining({
        uri: "/auth~feat-branch/some/path",
        origin: expect.objectContaining({
          custom: expect.objectContaining({
            domainName: "feat-branch.example.com"
          })
        }),
        headers: expect.objectContaining({
          host: [{ key: 'host', value: 'feat-branch.example.com' }]
        })
      }));
    });

    test('Request should NOT be modified the request if the URI does not match the pattern', () => {
      event.Records[0].cf.request.uri = "/no-match-path";
      lambdaHandler.handler(event, context, callback);

      expect(callback).toHaveBeenCalledWith(null, expect.objectContaining({
        uri: "/no-match-path",
        headers: expect.objectContaining({
          host: [{ key: 'host', value: 'main.example.com' }]
        })
      }));
    });


    test('Paths with empty trailing parts should be preserved', () => {
      event.Records[0].cf.request.uri = "/auth~feat-branch/";

      lambdaHandler.handler(event, context, callback);

      expect(callback).toHaveBeenCalledWith(null, expect.objectContaining({
        uri: "/auth~feat-branch/",
        origin: expect.objectContaining({
          custom: expect.objectContaining({
            domainName: "feat-branch.example.com"
          })
        }),
        headers: expect.objectContaining({
          host: [{ key: 'host', value: 'feat-branch.example.com' }]
        })
      }));
    });
});
