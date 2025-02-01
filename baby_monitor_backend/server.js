const express = require("express");
const mongoose = require("mongoose");
const classifyRoute = require("./routes/classifyRoute");
const cors = require("cors");

const app = express();
const port = 8080;

// MongoDB Atlas Connection URI (Replace <db_password> with your actual password)
const MONGO_URI = "mongodb+srv://muhammedadilmp7:Adillida@7@cluster0.8wmnz.mongodb.net/mydatabase?retryWrites=true&w=majority";

// Enable CORS to allow requests from Flutter
app.use(cors());

// Connect to MongoDB before starting the server
mongoose
  .connect(MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => {
    console.log("MongoDB connected successfully!");

    // API Route
    app.use("/classify", classifyRoute);

    // Start Server
    app.listen(port, () => {
      console.log(`Server running on http://localhost:${port}`);
    });
  })
  .catch((err) => {
    console.error("MongoDB connection error:", err);
    process.exit(1); // Exit if MongoDB connection fails
  });
