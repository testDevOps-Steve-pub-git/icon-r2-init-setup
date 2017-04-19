var exec = require('child_process').exec

var createService = (serviceName, userName) => {
  return new Promise((resolve, reject) => {
    exec('cf create-service ' + serviceName + ' Standard ' + userName, (error, stdout, stderr) => {
      if (error) {
        reject(error)
      } else {
        console.log('service created: ', serviceName)
        resolve('done')
      }
    })
  })
}

var createServiceKey = (userName, credentialsName) => {
  return new Promise((resolve, reject) => {
    exec('cf create-service-key ' + userName + ' ' + credentialsName, (error, stdout, stderr) => {
      if (error) {
        reject(error)
      } else {
        console.log('service-key created: ', userName)
        resolve('done')
      }
    })
  })
}

let es = createService('compose-for-elasticsearch', 'icon-elasticsearch')
let pgl = createService('compose-for-postgresql', 'icon-postgresql')
let rmq = createService('compose-for-rabbitmq', 'icon-rabbitmq')

Promise.all([es, pgl, rmq]).then((result) => {
  console.log('compose service created')
  let esk = createServiceKey('icon-elasticsearch', 'Credentials-1')
  let pglk = createServiceKey('icon-postgresql', 'CCS-srv-binding-icon_setup_7-1492143347.94')
  let rmqk = createServiceKey('icon-rabbitmq', 'Credentials-1')

  Promise.all([esk, pglk, rmqk]).then((result) => {
    console.log('compose service keys created')
  })
})
