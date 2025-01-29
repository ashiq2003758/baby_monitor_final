const express = require('express');
const multer = require('multer');
const router = express.Router();

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'uploads/video/'),
  filename: (req, file, cb) => cb(null, `${Date.now()}-${file.originalname}`),
});

const upload = multer({ storage });

router.post('/upload', upload.single('video'), (req, res) => {
  res.status(200).json({ message: 'Video uploaded successfully', filePath: req.file.path });
});

module.exports = router;
