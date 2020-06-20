from flask import jsonify
from google.cloud import datastore

project_id = "YOUR PRJ-ID" # Your google project id in GCP.

def update_entry(request):
    """Update the entry.
    Args:
        request (flask.Request): HTTP request object.
    Returns:
        The response text or any set of values that can be turned into a
        Response object using
        `make_response <http://flask.pocoo.org/docs/1.0/api/#flask.Flask.make_response>`.
    """
    # [START update_entry]
    try:
        pos = request.args.get('pos')
        if not pos:
            return

        _cls = request.args.get('class')
        if not _cls:
            return
        cls = int(_cls)

        client = datastore.Client()
        with client.transaction():
            try:
                kind = 'tweet_entity'
                key = client.key(kind, pos)
                entry = client.get(key)

                entry["class"] = cls

                client.put(entry)
            except Exception as e:
                print(e.message)

            return jsonify({"pos" : pos, "class" : cls})
    except Exception as e:
        print(e.message)

    # [END update_entry]
