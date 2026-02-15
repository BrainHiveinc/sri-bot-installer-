#!/usr/bin/env python3
import hashlib
import json
from pathlib import Path
from datetime import datetime

LICENSE_FILE = Path.home() / ".agent-sri" / "license.json"

def validate_license():
    """Validate license key before running bot"""
    if not LICENSE_FILE.exists():
        print("❌ No license found")
        print("Contact: brainhiveinc@gmail.com for license")
        return False

    try:
        with open(LICENSE_FILE, 'r') as f:
            license_data = json.load(f)

        key = license_data.get('key', '')
        email = license_data.get('email', '')

        # Verify license key
        expected_hash = hashlib.sha256(f"{email}:BRAINHIVE2026".encode()).hexdigest()

        if key != expected_hash:
            print("❌ Invalid license key")
            return False

        print("✅ License validated")
        return True

    except Exception as e:
        print(f"❌ License error: {e}")
        return False

def create_license(email, output_file=None):
    """Generate license for customer"""
    key = hashlib.sha256(f"{email}:BRAINHIVE2026".encode()).hexdigest()

    license_data = {
        "email": email,
        "key": key,
        "issued": datetime.now().isoformat(),
        "product": "Agent Sri"
    }

    if output_file:
        with open(output_file, 'w') as f:
            json.dump(license_data, f, indent=2)
        print(f"License created: {output_file}")

    return license_data

if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1:
        email = sys.argv[1]
        create_license(email, f"license_{email.split('@')[0]}.json")
    else:
        validate_license()
