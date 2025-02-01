import sys
import numpy as np
import tensorflow as tf
from tensorflow.keras.models import load_model
from sklearn.preprocessing import LabelEncoder
import pickle
from PIL import Image

# Load the trained model
model = load_model('model/baby_image_model.h5')

# Load the LabelEncoder (make sure you use the correct path for your LabelEncoder file)
with open('model/label_encoder2.pkl', 'rb') as f:
    label_encoder = pickle.load(f)

# Function to preprocess image and make prediction
def predict_image(image_path):
    # Load image using Pillow
    img = Image.open(image_path)
    
    # Resize the image to the expected input size (128x128)
    img = img.resize((128, 128))
    
    # Convert image to numpy array
    img = np.array(img)
    
    # Normalize the image
    img = img / 255.0
    
    # If the image has an alpha channel (RGBA), convert to RGB
    if img.shape[-1] == 4:
        img = img[..., :3]
    
    # Reshape the image to match the input shape (1, 128, 128, 3)
    img = np.expand_dims(img, axis=0)
    
    # Make prediction
    predictions = model.predict(img)
    predicted_class_index = np.argmax(predictions, axis=1)[0]
    
    # Get the predicted label from the label encoder
    predicted_label = label_encoder.inverse_transform([predicted_class_index])[0]
    
    print(f"Predicted emotion: {predicted_label}")

# Check if image path is passed as argument
if len(sys.argv) != 2:
    print("Usage: python predict.py <image_path>")
    sys.exit(1)

# Get the image path from the command-line arguments
image_path = sys.argv[1]

# Predict the image
predict_image(image_path)
