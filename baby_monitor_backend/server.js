const express = require("express");
const classifyRoute = require("./routes/classifyRoute");
const cors = require("cors");

const app = express();
const port = 8080;

// Enable CORS to allow requests from Flutter
app.use(cors());

// API Route
app.use("/classify", classifyRoute);

// Start Server
app.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`);
});
