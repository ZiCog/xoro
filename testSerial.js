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
let message = 'Now is the time for all good men to come to the aid of the party\0'


port.on('data', function (inBuff) {
  process.stdout.write(inBuff)
  rxCount += inBuff.length

})


let sendMsgs = function () {
  port.write(message, 'binary', function () {
    txCount += message.length
    setTimeout(sendMsgs, 10)
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
