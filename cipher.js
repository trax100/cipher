const getopts = require("getopts")

const HELPTEXT = `Usage: cipher --mode=(encode|decode) --type=(morse|rot13) --message=MESSAGE

  --interactive     enter interactive mode
  --message         message to be processed
  --type            available ciphers are MORSE & ROT13
  --mode            encode or decode
  --verbose         verbose mode
`;


const MORSECODES = {
    'a': '.-',
    'b': '-...',
    'c': '-.-.',
    'd': '-..',
    'e': '.',
    'f': '..-.',
    'g': '--.',
    'h': '....',
    'i': '..',
    'j': '.---',
    'k': '-.-',
    'l': '.-..',
    'm': '--',
    'n': '-.',
    'o': '---',
    'p': '.--.',
    'q': '--.-',
    'r': '.-.',
    's': '...',
    't': '-',
    'u': '..-',
    'v': '...-',
    'w': '.--',
    'x': '-..-',
    'y': '-.--',
    'z': '--..',
    ' ': '/',
    '1': '.----',
    '2': '..---',
    '3': '...--',
    '4': '....-',
    '5': '.....',
    '6': '-....',
    '7': '--...',
    '8': '---..',
    '9': '----.',
    '0': '-----',
}

const ciphers = {};

const rot13=s=>s.replace(/[a-z]/ig,c=>Buffer.from([((d=Buffer.from(c)[0])&95)<78?d+13:d-13]));
ciphers.rot13 = {};
ciphers.rot13.encode = rot13;
ciphers.rot13.decode = rot13;

ciphers.morse = {
    encode: (msg) => {
        return msg
            .toLowerCase()              // Make lowercase
            .replace(/[^a-z0-9 ]/g, '') // Sanitize input
            .split('')                  // Transform the string into an array: ['T', 'h', 'i', 's'...
            .map(e => MORSECODES[e])    // Replace each character with a morse "letter"
            .join(' ')                  // Convert the array back to a string.
        ;
    },
    decode: (msg) => {
        const decoder = {};
        // Create mapping table (morse code >> letter)
        Object.entries(MORSECODES).reduce((_, current) => decoder[current[1]] = current[0]);

        return msg
            .replace(/[^.\-/ ]/g, '')   // Sanitize input
            .split(' ')                 // Transform to an array
            .map(d => decoder[d])       // Replace each morse "letter" with a character
            .join('')                   // Convert the array back to a string.
        ;
    }
}

function main() {
    const options = getopts(process.argv.slice(2), {
        booleans: ["i", "e", "v"]
    })

    if (options.verbose) console.log(options);

    if (options.help) {
        console.log(HELPTEXT);
        return 0;
    }

    if (options.type in ciphers) {
        if (options.interactive) {
            console.log('Interactive mode.\nPress Ctrl+C to exit');
            const readline = require('readline');

            readline.emitKeypressEvents(process.stdin);
            process.stdin.setRawMode(true);

            process.stdin.on('keypress', (str, key) => {
                if (key.sequence == '\u0003') {
                    process.exit();
                }
                if (options.verbose) console.log(msg);
                console.log( ciphers[ options.type ][ options.mode ](key.sequence));
            })

        } else if (options.message) {
            console.log( ciphers[ options.type ][ options.mode ](options.message.toString()));

        } else {
            console.log(22);
        }

    } else {
        console.log('Unknown cipher type.');
        return -2;
    }
}

main();