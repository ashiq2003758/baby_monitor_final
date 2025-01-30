
const { exec } = require("child_process");

function classifyAudio(audioPath) {
    return new Promise((resolve, reject) => {
        exec(`python classify.py ${audioPath}`, (error, stdout, stderr) => {
            if (error) {
                console.error(stderr);
                reject("Error processing audio.");
            }
            resolve(JSON.parse(stdout));
        });
    });
}

module.exports = classifyAudio;
