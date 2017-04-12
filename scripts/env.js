var obj = require('./services.json')
var fs = require('fs')

var iconelasticsearch = obj['compose-for-elasticsearch'][0]['credentials']['uri']
var iconpostgresql = obj['compose-for-postgresql'][0]['credentials']['uri']
var iconrabbitmq = obj['compose-for-rabbitmq'][0]['credentials']['uri']

var JWT_TOKEN_SECRET_KEY = obj['user-provided'][0]['credentials']['JWT_TOKEN_SECRET_KEY']
var CRYPTO_PASSWORD = obj['user-provided'][0]['credentials']['CRYPTO_PASSWORD']

var POSTGRES_READONLY_ROLE = obj['user-provided'][0]['credentials']['POSTGRES_READONLY_ROLE']
var PHIX_ENDPOINT_DICTIONARY = obj['user-provided'][0]['credentials']['PHIX_ENDPOINT_DICTIONARY']
var CLAMAV_ENDPOINT = obj['user-provided'][0]['credentials']['CLAMAV_ENDPOINT']
var PHIX_ENDPOINT_SUBMISSION = obj['user-provided'][0]['credentials']['PHIX_ENDPOINT_SUBMISSION']
var PHIX_ENDPOINT_SUBMISSION_TOKEN = obj['user-provided'][0]['credentials']['PHIX_ENDPOINT_SUBMISSION_TOKEN']
var PHIX_ENDPOINT_RETRIEVAL = obj['user-provided'][0]['credentials']['PHIX_ENDPOINT_RETRIEVAL']
var PHIX_ENDPOINT_RETRIEVAL_TOKEN = obj['user-provided'][0]['credentials']['PHIX_ENDPOINT_RETRIEVAL_TOKEN']

var json = {
  'icon-elasticsearch': iconelasticsearch,
  'icon-postgresql': iconpostgresql,
  'icon-rabbitmq': iconrabbitmq,
  JWT_TOKEN_SECRET_KEY,
  CRYPTO_PASSWORD,
  POSTGRES_READONLY_ROLE,
  PHIX_ENDPOINT_DICTIONARY,
  CLAMAV_ENDPOINT,
  PHIX_ENDPOINT_SUBMISSION,
  PHIX_ENDPOINT_SUBMISSION_TOKEN,
  PHIX_ENDPOINT_RETRIEVAL,
  PHIX_ENDPOINT_RETRIEVAL_TOKEN
}

fs.writeFile('local.json', JSON.stringify(json), function (err) {
  if (err) throw err
})
