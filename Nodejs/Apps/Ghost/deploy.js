var GHOST_ZIP_URL = 'http://ghost.org/zip/ghost-0.3.3.zip';
var GHOST_ZIP_FILE = 'ghost-0.3.3.zip';
var ZOO_HOME = '%SystemDrive%\\Zoo';
var COMMANDS = [
  ZOO_HOME+'\\Tools\\wget.exe --no-check-certificate -O '+GHOST_ZIP_FILE+' '+GHOST_ZIP_URL,
  ZOO_HOME+'\\Tools\\7za.exe x -y '+GHOST_ZIP_FILE,
  'copy config.example.js config.js',
  fixPortInSettings,
  'node -v', 
  'npm -v', 
  'npm install --production',
  'if exist %SystemRoot%\\Temp\\node-sqlite3-Release rmdir %SystemRoot%\\Temp\\node-sqlite3-Release /S /Q'
];

main();

function main(){

  execCommands();
}

function fixPortInSettings(){
  var filename = 'config.js';
  var fs = require('fs');
  fs.readFile(filename, 'utf8', function (err,data) {
    if (err) {
      return console.log(err);
    }
    var result = data.replace(/port:\s*'?2368'?/g, "port: process.env.PORT||2368");

    fs.writeFile(filename, result, 'utf8', function (err) {
      if (err) return console.log(err);
      execCommands();
    });
  });
}

function execCommands() {

  var child_process = require('child_process');
  var execFile = child_process.execFile;
  var systemRoot = process.env.SYSTEMROOT;
  if (systemRoot.length == 0){
    systemRoot = "c:\\windows";
  }

  if (COMMANDS.length > 0) {
    var command = COMMANDS.shift();

    if (typeof(command) == 'function') {
      console.log('calling function: '+ command);
      command();
    } else {
      console.log('executing command: '+ command);
      var child = execFile(systemRoot + '\\system32\\cmd.exe', ['/s', '/c', command],
        function (error, stdout, stderr) {
          console.log('stdout: ' + stdout);
          console.log('stderr: ' + stderr);
          if (error !== null) {
            console.log('exec error: ' + error);
          }
      });
      child.on('exit', function(code) {
        console.log('process '+ command +' exited with exit code: '+code);
        if (code == 0) {
          execCommands();
        }
        else {
          setTimeout(function(){
            console.log('\nexiting with exit code: '+code);
            process.exit(code);
          }, 2000);
        }
      });
    }
  }
}

