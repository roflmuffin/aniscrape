class ScraperError extends Error
  constructor: (@message) ->
    @name = this.constructor.name
    if Error.captureStackTrace
      Error.captureStackTrace this, this.constructor
    else
      Error.call this

class SearchProviderFormatError extends ScraperError
  constructor: (provider, @message) ->
    if provider.name?
      @message = "[#{provider.name}] #{@message}"
    super(@message)

module.exports =
  ScraperError: ScraperError
  SearchProviderFormatError: SearchProviderFormatError