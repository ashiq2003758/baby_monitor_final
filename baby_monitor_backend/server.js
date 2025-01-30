const express = require("express");
const multer = require("multer");
const classifyRoute = require("./routes/classifyRoute");

const app = express();
const port = 8080;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// API Routes
app.use("/classify", classifyRoute);

// Start Server
app.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`);
});
