import requests
import time
import random

ERROR_URL = "http://web:5000/error"
ROOT_URL = "http://web:5000/"

def send_requests(url, label):
    print(f"\n Sending 50 requests to {label}")
    for i in range(50):
        try:
            r = requests.get(url)
            print(f"[{label}] Status: {r.status_code}")
        except Exception as e:
            print(f"[{label}] Request failed: {e}")
        time.sleep(0.5)

def random_pause():
    delay = random.randint(10, 30)
    print(f"Pausing for {delay} seconds...\n")
    time.sleep(delay)

while True:
    send_requests(ERROR_URL, "ERROR")
    random_pause()

    send_requests(ROOT_URL, "ROOT")
    random_pause()
