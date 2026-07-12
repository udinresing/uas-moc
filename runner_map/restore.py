import urllib.request
import json
import os
import ssl

ssl._create_default_https_context = ssl._create_unverified_context

repo = "udinresing/uas-moc"
commit_sha = "a4cee44"
url = f"https://api.github.com/repos/{repo}/git/trees/{commit_sha}?recursive=1"

req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
with urllib.request.urlopen(req) as response:
    data = json.loads(response.read().decode())

for item in data.get('tree', []):
    if item['type'] == 'blob':
        path = item['path']
        if path.startswith('lib/') or path.startswith('test/') or path.startswith('web/') or path in ['pubspec.yaml', 'pubspec.lock', 'README.md', 'analysis_options.yaml']:
            print(f"Downloading {path}...")
            raw_url = f"https://raw.githubusercontent.com/{repo}/{commit_sha}/{path}"
            
            # Create directories if they don't exist
            os.makedirs(os.path.dirname(path) if os.path.dirname(path) else '.', exist_ok=True)
            
            try:
                raw_req = urllib.request.Request(raw_url, headers={'User-Agent': 'Mozilla/5.0'})
                with urllib.request.urlopen(raw_req) as raw_resp:
                    with open(path, 'wb') as f:
                        f.write(raw_resp.read())
            except Exception as e:
                print(f"Failed to download {path}: {e}")

print("Recovery complete!")
