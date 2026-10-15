"""Revoke signing certificates that earlier CI runs created through the App Store Connect API.

Each CI run starts on a clean machine, so Xcode's automatic signing makes a fresh certificate
every time and Apple's per-account limit fills up. Certificates created this way are named
"Created via API"; revoking them doesn't affect builds already uploaded to TestFlight.
"""
import json
import os
import sys
import time
import urllib.request

import jwt

key_id = os.environ["ASC_KEY_ID"]
issuer = os.environ["ASC_ISSUER_ID"]
with open(os.environ["KEY_PATH"]) as f:
    private_key = f.read()

now = int(time.time())
token = jwt.encode({"iss": issuer, "iat": now, "exp": now + 600, "aud": "appstoreconnect-v1"},
                   private_key, algorithm="ES256", headers={"kid": key_id, "typ": "JWT"})


def call(method, path):
    req = urllib.request.Request("https://api.appstoreconnect.apple.com" + path, method=method,
                                 headers={"Authorization": "Bearer " + token})
    with urllib.request.urlopen(req) as resp:
        body = resp.read()
        return json.loads(body) if body else None


certs = call("GET", "/v1/certificates?limit=200")["data"]
revoked = 0
for cert in certs:
    attrs = cert["attributes"]
    label = f'{attrs.get("certificateType")} "{attrs.get("displayName") or attrs.get("name")}" expires {attrs.get("expirationDate")}'
    names = " ".join(str(attrs.get(k) or "") for k in ("name", "displayName"))
    if "Created via API" in names:
        call("DELETE", f'/v1/certificates/{cert["id"]}')
        revoked += 1
        print("Revoked " + label)
    else:
        print("Kept " + label)
print(f"Revoked {revoked} of {len(certs)} certificates.")
sys.exit(0)
