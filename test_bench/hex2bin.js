const readline = require('readline');
const fs = require('fs');

const buf = Buffer.alloc(4);

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

rl.on('line', (line) => {
    buf.writeUInt32BE(parseInt(line, 16) >>> 0, 0);
    process.stdout.write(buf);
});



