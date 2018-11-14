let SerialPort = require('serialport')

let port = new SerialPort('/dev/ttyS7', {
	  baudRate: 115200,
	  stopBits: 1
});

let packetLength = 1 
let lastChar = -1
let txCount = 0
let rxCount = 0
let errorCount = 0 
let message = 'NNNNNNNNNNNNNNNN'
let m =  'ow is the time for all good men to come to the aid of the party\0'


port.on('data', function (inBuff) {
  console.log(inBuff.toString('utf8'));
  process.stdout.write(inBuff.toString('utf8'))
  process.stdout.write('\n')

  rxCount += inBuff.length

})


let sendMsgs = function () {
  port.write(message, 'binary', function () {
    txCount += message.length
    setTimeout(sendMsgs, 1)
  })
}


sendMsgs()


process.on('SIGINT', function() {
  console.log("\nCaught interrupt signal")
  console.log("Tx bytes: ", txCount)
  console.log("Rx bytes: ", rxCount)
  console.log("Rx errors: ", errorCount)
  port.write('Force error', 'binary', function () {
    process.exit()
  })
})
