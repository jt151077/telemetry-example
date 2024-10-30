#
# Copyright 2021 Google LLC
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


import os
import functions_framework
import json

from flask import Flask, request
from google.cloud import pubsub_v1


app = Flask(__name__)


def post_to_pubsub(project_id, topic_id, message):
  try:
    publisher = pubsub_v1.PublisherClient()
    topic_path = publisher.topic_path(project_id, topic_id)
    message_json = json.dumps(message)
    data = message_json.encode("utf-8")

    # Publish the message
    future = publisher.publish(topic_path, data)
    print(f"Published message ID: {future.result()}")

  except Exception as e:
    print(f"Error publishing message: {e}")



@app.route("/collect", methods=["POST"])
def collect():
    content = json.loads(request.data)
    post_to_pubsub("jeremy-8pe35ar7", "telemetry", content)
    return json.dumps(content)


# [START eventarc_pubsub_server]
if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
# [END eventarc_pubsub_server]

