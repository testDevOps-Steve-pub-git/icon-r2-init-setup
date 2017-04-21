var exec = require('child_process').exec

let esServiceName = 'compose-for-elasticsearch'
let pglServiceName = 'compose-for-postgresql'
let rmqServiceName = 'compose-for-rabbitmq'

let esUserDefinedName = 'icon-elasticsearch'
let pglUserDefinedName = 'icon-postgresql'
let rmqUserDefinedName = 'icon-rabbitmq'

var checkService = (serviceName) => {
  return new Promise((resolve, reject) => {
    exec('cf service ' + serviceName + ' --guid', (error, stdout, stderr) => {
      if (error) {
        resolve('done')
      } else {
        reject(error)
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
        console.log('service created: ', serviceName)
        resolve('done')
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
        console.log('service-key created: ', userDefinedName)
        resolve('done')
      }
    })
  })
}








let esCheck = checkService(esUserDefinedName)
let pglCheck = checkService(pglUserDefinedName)
let rmqCheck = checkService(rmqUserDefinedName)

Promise.all([esCheck, pglCheck, rmqCheck]).then((result) => {
  console.log('start creating services')
  let es = createService(esServiceName, esUserDefinedName)
  let pgl = createService(pglServiceName, pglUserDefinedName)
  let rmq = createService(rmqServiceName, rmqUserDefinedName)

  Promise.all([es, pgl, rmq]).then((result) => {
    console.log('compose service created')
    let esk = createServiceKey(esUserDefinedName, 'Credentials-1')
    let pglk = createServiceKey(pglUserDefinedName, 'Credentials-1')
    let rmqk = createServiceKey(rmqUserDefinedName, 'Credentials-1')

    Promise.all([esk, pglk, rmqk]).then((result) => {
      console.log('compose service keys created')
    })
  })


}
).catch((reason)=>{
   console.log('services already exist, stop creating services')
  process.exit(1)
    
})


