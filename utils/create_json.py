import json
import argparse
import os

def main():
    # Set up argument parser
    parser = argparse.ArgumentParser(description="Generate test result JSON.")
    parser.add_argument("--test_name", required=True, help="The name of the test.")
    parser.add_argument("--script_name", required=True, help="The name of the script.")
    parser.add_argument("--result", required=True, help="The result of the test.")
    parser.add_argument("--file_path", help="Path to the file containing error stack (optional).")
    
    args = parser.parse_args()
    
    # Read and process the file content if file_path is provided
    if args.file_path:
        if os.path.exists(args.file_path):
            with open(args.file_path, "r") as file:
                file_content = file.read()
        else:
            file_content = "File not found."
    else:
        file_content = ""

    # Prepare the JSON object
    output = {
        "test_name": args.test_name,
        "script_name": args.script_name,
        "result": args.result,
        "error_stack": file_content
    }

    # Convert to JSON and add a trailing comma
    json_output = json.dumps(output, indent=4, ensure_ascii=False)

    print(json_output + ",")

if __name__ == "__main__":
    main()
