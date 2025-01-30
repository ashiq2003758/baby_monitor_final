import os
import json
import librosa
import numpy as np
import tensorflow as tf
import joblib

# Load the trained model and label encoder
MODEL_PATH = "model/baby_cry_model.h5"
ENCODER_PATH = "model/label_encoder.pkl"
UPLOADS_FOLDER = "uploads/"

# Load model and label encoder
model = tf.keras.models.load_model(MODEL_PATH)
label_encoder = joblib.load(ENCODER_PATH)

def get_latest_audio_file(directory):
    """Finds the most recently uploaded .wav file in the given directory."""
    files = [f for f in os.listdir(directory) if f.endswith(".wav")]
    if not files:
        return None  # No audio files found
    
    # Get the latest file based on modification time
    latest_file = max(files, key=lambda f: os.path.getmtime(os.path.join(directory, f)))
    return os.path.join(directory, latest_file)

def classify_audio(file_path):
    """Processes the audio file and returns the predicted label."""
    # Load audio file
    y, sr = librosa.load(file_path, sr=16000)

    # Generate Mel Spectrogram
    mel_spec = librosa.feature.melspectrogram(y=y, sr=sr, n_mels=128)
    mel_spec_db = librosa.power_to_db(mel_spec, ref=np.max)

    # Resize Mel Spectrogram to match expected input shape (128, 130)
    mel_spec_db = np.expand_dims(mel_spec_db, axis=0)  # Add batch dimension
    mel_spec_db = np.expand_dims(mel_spec_db, axis=-1) # Add channel dimension

    # Resize to (128, 130) using interpolation or padding/truncating
    target_height = 128  # This should already be correct
    target_width = 130

    # If the current width is smaller, pad it
    if mel_spec_db.shape[2] < target_width:
        mel_spec_db = np.pad(mel_spec_db, ((0, 0), (0, 0), (0, target_width - mel_spec_db.shape[2]), (0, 0)), mode='constant')
    elif mel_spec_db.shape[2] > target_width:
        mel_spec_db = mel_spec_db[:, :, :target_width, :]  # Truncate

    # Ensure the shape is (1, 128, 130, 1)
    assert mel_spec_db.shape == (1, 128, 130, 1), f"Unexpected shape: {mel_spec_db.shape}"

    # Make prediction
    prediction = model.predict(mel_spec_db)
    predicted_class = np.argmax(prediction)
    predicted_label = label_encoder.inverse_transform([predicted_class])[0]

    return predicted_label


if __name__ == "__main__":
    print(1)
    latest_file = get_latest_audio_file(UPLOADS_FOLDER)

    if latest_file:
        result = classify_audio(latest_file)
        print(json.dumps({"file": latest_file, "prediction": result}))
    else:
        print(json.dumps({"error": "No audio file found in uploads/"}))
