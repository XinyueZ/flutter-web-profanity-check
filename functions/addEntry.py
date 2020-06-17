import time
import urllib.parse
from flask import jsonify
from google.cloud import datastore

project_id = "YOUR PRJ-ID" # Your google project id in GCP.

def add_entry(request):
    """Add new entry.
    Args:
        request (flask.Request): HTTP request object.
    Returns:
        The response text or any set of values that can be turned into a
        Response object using
        `make_response <http://flask.pocoo.org/docs/1.0/api/#flask.Flask.make_response>`.
    """
    # [START add_entry]
    tweet = urllib.parse.unquote(request.args.get('tweet'))
    if not tweet:
        return

    _cls = urllib.parse.unquote(request.args.get('class'))
    if not _cls:
        return
    cls = int(_cls)

    r = {}
    client = datastore.Client()
    with client.transaction():
         # The kind for the new entity
        kind = 'tweet_entity'
        # The Cloud Datastore key for the new entity
        pos = int(time.time())
        key = client.key(kind, "{}".format(pos))
        entry = datastore.Entity(key)
        entry_value = {
            'pos': pos,
            'count': 0,
            'hate_speech': 0,
            'offensive_language': 0,
            'neither': 0,
            'class': cls,
            'tweet' : tweet
        }
        entry.update(entry_value)
        client.put(entry)

        return jsonify({"pos" : pos})

    # [END add_entry]
