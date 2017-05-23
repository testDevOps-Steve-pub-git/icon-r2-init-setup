# Scripts documentation: 

## icon-r2-backend:

### env.js:
Parses the 3 compose services - `Elastic search, postgreSQL, RabbitMQ` along with the user provided service called `env_setup`. It also retrieves PHIX_ENDPOINT information such as `PHIX_ENDPOINT_DICTIONARY, PHIX_ENDPOINT_RETRIEVAL and PHIX_ENDPOINT_SUBMISSION` and writes to a `local.json` file necessary to run the tests on the pipeline. Its promisified so if any step fails, the promise will reject.

Following are the main functions inside env.js:

##### parseService('serviceName')
It parses the service specified from Bluemix and returns that using `cf service-key` and the app is not required to be created beforehand.

##### parseUserProvidedService('serviceName')
It parses the user provided service specified that is already created from Bluemix and returns that using cf service and the app is not required to be created beforehand.

### read_properties.sh:
```usage: read_properties.sh <file-name-to-read-property-from> <propertyName>```

Reads the properties defined in the format key=val from the file specified.

### slack-webhook.sh:
```usage: slack-webhook.sh <webhook-url> <channel> <username> <message>```

It posts a slack message using the webhook URL, channel name, user name and message specified. The webhook URL, channel needs to be created beforehand. The user name and message can be custom. To explore, you can find more information on https://api.slack.com/incoming-webhooks

## icon-r2-init-setup:

### create-services.sh:
Creates the 3 compose services i.e. elasticsearch, postgreSQL and rabbitMQ along with their service keys.

### create-user-provided-service.sh:
```usage: bash create-user-provided-service.sh [-f  <file path to JSON file>]```

It creates a user provided service from the file specified. If user provided service already exists then it updates the service with key, value pairs from the file.


### exec_psql.sh:
```usage: exec_psql service-user-defined-name credential-name```

It retrieves the userName, dbName, port and host from the service and credential name specified. It then executes the scripts of dropping db, adding roles, creating lookup db, create submit db, running the Geocode data SQL and lookup data SQL file. The serviceName and credentialName must exist on Bluemix with the information needed for it to successfully execute PSQL.

### one-time-setup.js:
```usage: one-time-setup.js serviceName userDefinedNameOfService credentialsName```

It does the one time setup of checking if the service with the name specified even exists, create the service if it does not exist, create the service key with the name specified. This script is very important for the one time setup stage on Bluemix devops pipeline.

### rm_sql.sh:
It checks if the container name exists using `cf ic inspect` Status and removes it once its ready to be shutdown.

### services.sh:
It retrieves the `VCAP_SERVICES` environment information from the application name specified. The app must be created for this script to execute. On devops environment, this script will not work as `VCAP_SERVICES` environment variable is not available.
