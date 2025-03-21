from flask import Flask, request, jsonify
from flask_cors import CORS  
import numpy as np
import joblib
import os

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})  # Allow all origins

# Load the saved model
model_path = os.path.join(os.path.dirname(__file__), 'insurance_model.pkl')
model = joblib.load(model_path)

@app.route('/predict', methods=['POST'])
def predict():
    try:
        if not request.is_json:
            return jsonify({'error': 'Invalid JSON format'}), 400
        
        data = request.get_json()
        print("Received Data:", data)  # Debugging log

        # Validate required fields
        required_fields = ['age', 'bmi', 'children', 'smoker', 'gender', 'region_nw', 'region_se', 'region_sw']
        missing_fields = [field for field in required_fields if field not in data]
        if missing_fields:
            return jsonify({'error': f'Missing fields: {", ".join(missing_fields)}'}), 400

        # Convert inputs safely
        try:
            input_data = np.array([[  
                int(data.get('age', 0)),  
                float(data.get('bmi', 0.0)),  
                int(data.get('children', 0)),  
                int(data.get('smoker', 0)),  
                int(data.get('gender', 0)),  
                int(data.get('region_nw', 0)),  
                int(data.get('region_se', 0)),  
                int(data.get('region_sw', 0))  
            ]])
        except ValueError:
            return jsonify({'error': 'Invalid input types. Ensure numbers are used correctly.'}), 400

        # Make prediction
        prediction = model.predict(input_data)[0]
        return jsonify({'estimated_cost': round(prediction, 2)})

    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
