import urllib.parse
from flask import escape
from flask import jsonify
from google.cloud import automl_v1beta1 as automl

project_id = "project_id" # Your google project id in GCP.
model_id = "model_id" # The model's ID deployed in the GCP.
region = 'region' # The location where you deployed your model.
client_options = {'api_endpoint': 'eu-automl.googleapis.com:443'} # Optional, for "eu-", you deployed your model in EU region.

def get_model(request):
    """Get a model."""
    # [START get_model]
    client = automl.AutoMlClient(client_options=client_options)
    model_path = client.model_path(project_id, region, model_id)
    model = client.get_model(model_path)

    # Retrieve deployment state.
    if model.deployment_state == automl.enums.Model.DeploymentState.DEPLOYED:
        deployment_state = "deployed"
    else:
        deployment_state = "undeployed"

    # Display the model information.
    print("Model name: {}".format(model.name))
    print("Model id: {}".format(model.name.split("/")[-1]))
    print("Model display name: {}".format(model.display_name))
    print("Model create time:")
    print("\tseconds: {}".format(model.create_time.seconds))
    print("\tnanos: {}".format(model.create_time.nanos))
    print("Model deployment state: {}".format(deployment_state))

    return model
    # [END get_model]

def read_request(request):
    """Read the argument in the request."""
    if request.args and 'q' in request.args:
        q = request.args.get('q')
        return urllib.parse.unquote(q)
    else:
        return None

def write_response(data):
    r = jsonify(data)
    r.headers['Access-Control-Allow-Origin'] = '*'
    return r

def predict_with_model(request):
    """Predict request content with model."""
    # [START predict_with_model]
    model = get_model(request)

    data_response = {}

    q = read_request(request)
    data_response["q"] = escape(q)
    print("Predict with a model for: {}".format(q))

    print("Setup TablesClient")
    try:
        client = automl.TablesClient(
            project=project_id,
            region=region,
            client_options=client_options
        )
    except Exception as e:
        print(e.message)

    print("Prediction start")
    try:
        response = client.predict(
            model=model,
            inputs=[q],
            feature_importance=True
        )
    except Exception as e:
        print(e.message)

    print("Prediction results")
    for result in response.payload:
        data_response[escape(result.tables.value.string_value)] = round(result.tables.score, 3)
        print("Predicted class name: {}, score: {}".format(
            result.tables.value.string_value,
            result.tables.score)
        )

    print("Prediction finished")
    r = write_response(data_response)
    # [END predict_with_model]
    return r
