const express = require("express");
const multer = require("multer");
const classifyAudio = require("../classifyAudio");

const router = express.Router();

// Configure multer for file uploads with validation for audio files
const upload = multer({
    dest: "uploads/",
    fileFilter: (req, file, cb) => {
        if (file.mimetype.startsWith("audio/")) {
            cb(null, true);
        } else {
            cb(new Error("Not an audio file!"), false);
        }
    },
});

router.post("/", upload.single("audio"), async (req, res) => {
    try {
        // Ensure file is uploaded
        if (!req.file) {
            return res.status(400).json({ error: "No audio file uploaded." });
        }

        const audioPath = req.file.path;
        const result = await classifyAudio(audioPath);

        // Optionally clean up the uploaded file
        // fs.unlinkSync(audioPath);  // Uncomment if you want to delete the file after processing

        // Send classification result as a JSON response
        res.json({
            label: result.label,
            confidence: result.confidence,
        });
    } catch (error) {
        console.error(error); // Log the error for debugging
        res.status(500).json({ error: "Audio processing failed.", details: error.message });
    }
});

module.exports = router;
