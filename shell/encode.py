import argparse
import base64

parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input", default="payload.py")
args = parser.parse_args()

with open(args.input, "r") as f:
    text = f.read()
    print("=== Original text content:")
    print(text)
    print("===<")

    encoded_bytes = base64.b64encode(text.encode("ascii"))
    encoded_string = encoded_bytes.decode("ascii")
    print("\n=== Encoded string:")
    print(encoded_string)
    print("===<")

    # Complete payload
    template = f"python -c \"import base64 as b;s=b.b64decode('{encoded_string}'.encode('ascii')).decode('ascii');exec(s)\""
    print("\n== Full:")
    print(template)
    print("===<")
