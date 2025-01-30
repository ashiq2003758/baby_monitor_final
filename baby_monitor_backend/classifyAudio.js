const { exec } = require("child_process");

function classifyAudio(audioPath) {
    return new Promise((resolve, reject) => {
        exec(`python classify.py "${audioPath}"`, (error, stdout, stderr) => {
            if (error) {
                console.error("Error running Python script:", stderr);
                reject({ error: "Audio processing failed." });
                return;
            }
            try {
                const result = JSON.parse(stdout);
                resolve(result);
            } catch (parseError) {
                console.error("Error parsing Python output:", parseError);
                reject({ error: "Invalid response from Python script." });
            }
        });
    });
}

module.exports = classifyAudio;
