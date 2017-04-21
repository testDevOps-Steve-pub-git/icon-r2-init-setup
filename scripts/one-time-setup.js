var exec = require('child_process').exec

let esServiceName = 'compose-for-elasticsearch'
let pglServiceName = 'compose-for-postgresql'
let rmqServiceName = 'compose-for-rabbitmq'

let esUserDefinedName = 'icon-elasticsearch'
let pglUserDefinedName = 'icon-postgresql'
let rmqUserDefinedName = 'icon-rabbitmq'

let isError = false

var checkService = (serviceName) => {
  return new Promise((resolve, reject) => {
    exec('cf services | grep ' +  serviceName + ' | wc -l', (error, stdout, stderr) => {
      if (error) {
        reject(error)
      } else {
        if(stdout == 0){
          resolve('Service does not exist: ' + serviceName)
        }else{
          reject('Service ' + serviceName + ' already exists')
        }
      }
    })
  })
}

var createService = (serviceName, userDefinedName) => {
  return new Promise((resolve, reject) => {
    exec('cf create-service ' + serviceName + ' Standard ' + userDefinedName, (error, stdout, stderr) => {
      if (error) {
        reject(error)
      } else {
        resolve('Service created: ' + serviceName)
      }
    })
  })
}

var createServiceKey = (userDefinedName, credentialsName) => {
  return new Promise((resolve, reject) => {
    exec('cf create-service-key ' + userDefinedName + ' ' + credentialsName, (error, stdout, stderr) => {
      if (error) {
        reject(error)
      } else {
        resolve('service-key created: ' + userDefinedName)
      }
    })
  })
}

var promisify = (serviceName, userDefinedName) => {
  checkService(userDefinedName).then((result) => {
    console.log(result)
    createService(serviceName, userDefinedName).then((result) => {
       console.log(result)
      createServiceKey(userDefinedName, 'Credentials-1').then(result => {
        console.log(result)
      }, (error) => {
        console.log(error)
        isError = true
      })
    }, (error) => {
      console.log(error)
      isError = true
    })
  }).catch(error =>{
    console.log(error)
    isError = true
  })
}

console.log('Creating services...')
promisify(esServiceName, esUserDefinedName)
promisify(pglServiceName, pglUserDefinedName)
promisify(rmqServiceName, rmqUserDefinedName)

if (isError) {
  process.exit(1)
}